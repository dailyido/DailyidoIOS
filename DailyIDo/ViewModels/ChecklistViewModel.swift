import Foundation
import UIKit
import SwiftUI

@MainActor
final class ChecklistViewModel: ObservableObject {
    @Published var checklistItems: [String: [ChecklistDisplayItem]] = [:]
    @Published var completedTipIds: Set<UUID> = []
    @Published var expandedItemId: UUID?
    @Published var collapsedSections: Set<String> = []
    @Published var isLoading = true

    private let tipService = TipService.shared
    private let supabase = SupabaseService.shared
    private let authService = AuthService.shared

    var user: User? { authService.currentUser }

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

            for (category, tips) in groupedTips {
                // Filter out tips with empty titles
                let validTips = tips.filter { !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
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

    // Auto-collapse sections that the user has already passed
    func setupInitialCollapsedState() {
        let currentDisplayOrder = currentMonthCategory.displayOrder
        for category in sortedCategories {
            guard let monthCategory = MonthCategory(rawValue: category) else { continue }
            // Only collapse sections the user has PASSED (lower displayOrder = further from wedding)
            // Don't collapse current or future (locked) sections
            if monthCategory.displayOrder < currentDisplayOrder {
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
}
