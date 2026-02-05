import Foundation
import UIKit
import SwiftUI
import Combine

@MainActor
final class ChecklistViewModel: ObservableObject {
    @Published var checklistItems: [String: [ChecklistDisplayItem]] = [:]
    @Published var completedTipIds: Set<UUID> = []
    @Published var expandedItemId: UUID?
    @Published var collapsedSections: Set<String> = []
    @Published var isLoading = true
    @Published var favoriteTips: [Tip] = []
    @Published var isFavoritesSectionCollapsed = false

    private let tipService = TipService.shared
    private let supabase = SupabaseService.shared
    private let authService = AuthService.shared
    private let favoritesService = FavoritesService.shared
    private var cancellables = Set<AnyCancellable>()

    var user: User? { authService.currentUser }

    init() {
        setupFavoritesSubscription()
    }

    private func setupFavoritesSubscription() {
        favoritesService.$favoriteTipIds
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { [weak self] in
                    await self?.loadFavoriteTips()
                }
            }
            .store(in: &cancellables)
    }

    // Current days until wedding
    var daysUntilWedding: Int {
        guard let weddingDate = user?.weddingDate else { return 365 }
        return Date().daysUntil(weddingDate)
    }

    // Get the user's current month category based on days out
    var currentMonthCategory: MonthCategory {
        MonthCategory.category(forDaysOut: daysUntilWedding)
    }

    // Check if a category should be locked (too far in advance)
    func isCategoryLocked(_ categoryString: String) -> Bool {
        guard let category = MonthCategory(rawValue: categoryString) else { return false }
        // Lock categories that come AFTER the user's current timeframe
        // (higher displayOrder = closer to wedding = should be locked if user is further out)
        return category.displayOrder > currentMonthCategory.displayOrder
    }

    var sortedCategories: [String] {
        let categories = MonthCategory.allCases.map { $0.rawValue }
        return categories.filter { checklistItems[$0] != nil && !checklistItems[$0]!.isEmpty }
    }

    func loadData() async {
        isLoading = true

        guard let userId = user?.id else {
            isLoading = false
            return
        }

        do {
            // Load tips if not already loaded
            if tipService.tips.isEmpty {
                try await tipService.loadTips()
            }

            // Load user's completed checklist items
            let completedItems = try await supabase.fetchUserChecklist(userId: userId)
            completedTipIds = Set(completedItems.map { $0.tipId })

            // Build display items grouped by category
            let groupedTips = tipService.getChecklistTips(isTentedWedding: user?.isTentedWedding ?? false)

            var displayItems: [String: [ChecklistDisplayItem]] = [:]

            // Check if user has both wedding date and location for sunset time calculation
            let canCalculateSunset = user?.weddingDate != nil &&
                                     user?.weddingLatitude != nil &&
                                     user?.weddingLongitude != nil

            for (category, tips) in groupedTips {
                // Filter out tips with empty titles
                // Also filter out tips containing "XXXX" placeholder if user can't calculate sunset time
                let validTips = tips.filter { tip in
                    let hasValidTitle = !tip.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    let hasXXXXPlaceholder = tip.tipText.contains("XXXX")

                    // Skip tips with XXXX if we can't calculate sunset time
                    if hasXXXXPlaceholder && !canCalculateSunset {
                        return false
                    }
                    return hasValidTitle
                }
                displayItems[category] = validTips.map { tip in
                    ChecklistDisplayItem(
                        tip: tip,
                        isCompleted: completedTipIds.contains(tip.id),
                        completedAt: completedItems.first(where: { $0.tipId == tip.id })?.completedAt
                    )
                }
            }

            checklistItems = displayItems

            // Auto-collapse sections except the current timeframe
            setupInitialCollapsedState()

            // Load favorites
            await favoritesService.loadFavorites()
            await loadFavoriteTips()
        } catch {
            print("Error loading checklist: \(error)")
        }

        isLoading = false
    }

    func toggleItem(_ item: ChecklistDisplayItem) async {
        guard let userId = user?.id else { return }

        let tipId = item.tip.id
        let wasCompleted = completedTipIds.contains(tipId)

        // Optimistic update
        if wasCompleted {
            completedTipIds.remove(tipId)
            // Track uncomplete analytics
            AnalyticsService.shared.logChecklistUncompleted(tipId: tipId)
        } else {
            completedTipIds.insert(tipId)
            HapticManager.shared.checklistComplete()
            // Track completion analytics
            AnalyticsService.shared.logChecklistCompleted(tipId: tipId)
        }

        // Update local state
        updateLocalItem(tipId: tipId, isCompleted: !wasCompleted)

        // Persist to database
        do {
            if wasCompleted {
                print("📋 [Checklist] Removing item: \(tipId) for user: \(userId)")
                try await supabase.removeChecklistItem(userId: userId, tipId: tipId)
                print("📋 [Checklist] Successfully removed item")
            } else {
                print("📋 [Checklist] Adding item: \(tipId) for user: \(userId)")
                try await supabase.addChecklistItem(userId: userId, tipId: tipId)
                print("📋 [Checklist] Successfully added item")
            }
        } catch {
            // Revert on failure
            print("📋 [Checklist] ERROR - Reverting: \(error)")
            if wasCompleted {
                completedTipIds.insert(tipId)
            } else {
                completedTipIds.remove(tipId)
            }
            updateLocalItem(tipId: tipId, isCompleted: wasCompleted)
        }
    }

    private func updateLocalItem(tipId: UUID, isCompleted: Bool) {
        for (category, items) in checklistItems {
            if let index = items.firstIndex(where: { $0.tip.id == tipId }) {
                var updatedItems = items
                updatedItems[index] = ChecklistDisplayItem(
                    tip: items[index].tip,
                    isCompleted: isCompleted,
                    completedAt: isCompleted ? Date() : nil
                )
                checklistItems[category] = updatedItems
                break
            }
        }
    }

    func toggleExpanded(_ itemId: UUID) {
        HapticManager.shared.buttonTap()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            if expandedItemId == itemId {
                expandedItemId = nil
            } else {
                expandedItemId = itemId
            }
        }
    }

    func toggleSectionCollapsed(_ category: String) {
        HapticManager.shared.buttonTap()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if collapsedSections.contains(category) {
                collapsedSections.remove(category)
            } else {
                collapsedSections.insert(category)
                // Close any expanded item in this section
                if let expandedId = expandedItemId,
                   let items = checklistItems[category],
                   items.contains(where: { $0.id == expandedId }) {
                    expandedItemId = nil
                }
            }
        }
    }

    func isSectionCollapsed(_ category: String) -> Bool {
        collapsedSections.contains(category)
    }

    // Auto-collapse sections that the user has already passed OR are locked (future)
    // Only the current section should be expanded by default
    func setupInitialCollapsedState() {
        let currentDisplayOrder = currentMonthCategory.displayOrder
        for category in sortedCategories {
            guard let monthCategory = MonthCategory(rawValue: category) else { continue }
            // Collapse everything except the current section
            // Past sections: displayOrder < currentDisplayOrder
            // Locked/future sections: displayOrder > currentDisplayOrder
            if monthCategory.displayOrder != currentDisplayOrder {
                collapsedSections.insert(category)
            }
        }
    }

    func openAffiliateLink(_ urlString: String, tipId: UUID? = nil) {
        // Track affiliate link analytics
        if let tipId = tipId {
            AnalyticsService.shared.logAffiliateLinkTapped(tipId: tipId, url: urlString)
        }

        // Use URLHelper for better deep linking (especially for Spotify)
        URLHelper.openSmartURL(urlString)
    }

    func completionProgress(for category: String) -> (completed: Int, total: Int) {
        guard let items = checklistItems[category] else { return (0, 0) }
        let completed = items.filter { $0.isCompleted }.count
        return (completed, items.count)
    }

    // MARK: - Favorites

    func loadFavoriteTips() async {
        // Get all tips that match the favorite IDs
        let favoriteIds = favoritesService.favoriteTipIds
        print("📋 [Favorites] Loading favorite tips for IDs: \(favoriteIds)")

        guard !favoriteIds.isEmpty else {
            favoriteTips = []
            print("📋 [Favorites] No favorite IDs, clearing list")
            return
        }

        // Load tips if not already loaded
        if tipService.tips.isEmpty {
            do {
                try await tipService.loadTips()
            } catch {
                print("📋 [Favorites] Error loading tips: \(error)")
                return
            }
        }

        // Search in regular tips
        var foundTips = tipService.tips.filter { favoriteIds.contains($0.id) }
        print("📋 [Favorites] Found \(foundTips.count) in regular tips")

        // Also search in fun tips and convert to Tip
        let funTipsAsTips = tipService.funTips
            .filter { favoriteIds.contains($0.id) }
            .map { $0.toTip() }
        print("📋 [Favorites] Found \(funTipsAsTips.count) in fun tips")

        foundTips.append(contentsOf: funTipsAsTips)

        favoriteTips = foundTips
        print("📋 [Favorites] Total favorite tips loaded: \(favoriteTips.count)")
    }

    func toggleFavoritesSectionCollapsed() {
        HapticManager.shared.buttonTap()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isFavoritesSectionCollapsed.toggle()
        }
    }

    func removeFavorite(tipId: UUID) async {
        await favoritesService.removeFavorite(tipId: tipId)
    }
}
