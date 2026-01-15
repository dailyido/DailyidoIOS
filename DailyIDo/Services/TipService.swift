import Foundation

final class TipService: ObservableObject {
    static let shared = TipService()

    @Published var tips: [Tip] = []
    @Published var isLoading = true

    private let supabase = SupabaseService.shared

    private init() {}

    func loadTips() async throws {
        let fetchedTips = try await supabase.fetchAllTips()

        await MainActor.run {
            self.tips = fetchedTips
            self.isLoading = false
        }
    }

    func getTipForDay(daysUntilWedding: Int, isTentedWedding: Bool) -> Tip? {
        // Filter tips based on tented wedding status
        let filteredTips = tips.filter { tip in
            if isTentedWedding {
                return true // Show all tips for tented weddings
            } else {
                return tip.weddingType != "tented" // Exclude tented-specific tips
            }
        }

        // 1. Check for specific_day match first
        if let specificTip = filteredTips.first(where: { $0.specificDay == daysUntilWedding }) {
            return specificTip
        }

        // 2. Fall back to month_category pool
        let category = MonthCategory.category(forDaysOut: daysUntilWedding)
        let pool = filteredTips.filter { tip in
            tip.monthCategory == category.rawValue && tip.specificDay == nil
        }

        guard !pool.isEmpty else { return nil }

        // 3. Use day number as index to rotate through pool deterministically
        let index = abs(daysUntilWedding) % pool.count
        return pool[index]
    }

    func getChecklistTips(isTentedWedding: Bool) -> [String: [Tip]] {
        let checklistTips = tips.filter { tip in
            guard tip.onChecklist else { return false }

            if isTentedWedding {
                return true
            } else {
                return tip.weddingType != "tented"
            }
        }

        // Group by month category
        var grouped: [String: [Tip]] = [:]

        for tip in checklistTips {
            let category = tip.monthCategory ?? "General"
            if grouped[category] == nil {
                grouped[category] = []
            }
            grouped[category]?.append(tip)
        }

        // Sort each group by priority
        for (category, categoryTips) in grouped {
            grouped[category] = categoryTips.sorted { $0.priority < $1.priority }
        }

        return grouped
    }

    func getSortedCategories() -> [MonthCategory] {
        return MonthCategory.allCases.sorted { $0.displayOrder < $1.displayOrder }
    }
}
