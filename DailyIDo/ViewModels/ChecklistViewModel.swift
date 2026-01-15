import Foundation
import UIKit

@MainActor
final class ChecklistViewModel: ObservableObject {
    @Published var checklistItems: [String: [ChecklistDisplayItem]] = [:]
    @Published var completedTipIds: Set<UUID> = []
    @Published var expandedItemId: UUID?
    @Published var isLoading = true

    private let tipService = TipService.shared
    private let supabase = SupabaseService.shared
    private let authService = AuthService.shared

    var user: User? { authService.currentUser }

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
                displayItems[category] = tips.map { tip in
                    ChecklistDisplayItem(
                        tip: tip,
                        isCompleted: completedTipIds.contains(tip.id),
                        completedAt: completedItems.first(where: { $0.tipId == tip.id })?.completedAt
                    )
                }
            }

            checklistItems = displayItems
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
        } else {
            completedTipIds.insert(tipId)
            HapticManager.shared.checklistComplete()
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
        if expandedItemId == itemId {
            expandedItemId = nil
        } else {
            expandedItemId = itemId
        }
    }

    func openAffiliateLink(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }

    func completionProgress(for category: String) -> (completed: Int, total: Int) {
        guard let items = checklistItems[category] else { return (0, 0) }
        let completed = items.filter { $0.isCompleted }.count
        return (completed, items.count)
    }
}
