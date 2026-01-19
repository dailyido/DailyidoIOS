import Foundation

final class TipService: ObservableObject {
    static let shared = TipService()

    @Published var tips: [Tip] = []
    @Published var funTips: [FunTip] = []
    @Published var criticalTips: [Tip] = []  // First 50 tips for long engagements
    @Published var isLoading = true

    private let supabase = SupabaseService.shared

    // Cache for fun tips shown to user (to avoid repeated DB calls)
    private var userShownFunTipIds: Set<UUID> = []
    private var lastShownFunTipCategory: String?

    private init() {}

    func loadTips() async throws {
        let fetchedTips = try await supabase.fetchAllTips()
        let fetchedFunTips = try await supabase.fetchAllFunTips()
        let fetchedCriticalTips = try await supabase.fetchFirst50CriticalTips()

        await MainActor.run {
            self.tips = fetchedTips
            self.funTips = fetchedFunTips
            self.criticalTips = fetchedCriticalTips
            self.isLoading = false
        }
    }

    /// Load user's fun tip history for smart selection
    func loadUserFunTipHistory(userId: UUID) async {
        do {
            let shownIds = try await supabase.fetchUserShownFunTipIds(userId: userId)
            let lastCategory = try await supabase.fetchLastShownFunTipCategory(userId: userId)

            await MainActor.run {
                self.userShownFunTipIds = Set(shownIds)
                self.lastShownFunTipCategory = lastCategory
            }
        } catch {
            print("Error loading fun tip history: \(error)")
        }
    }

    // MARK: - Main Tip Selection Logic

    /// Get the appropriate tip for the given day
    /// This is the main entry point that handles both long and normal engagements
    func getTipForDay(user: User, daysUntilWedding: Int) -> Tip? {
        // SCENARIO 1: Long engagement (>350 days out)
        if daysUntilWedding > 350 {
            return getTipForLongEngagement(user: user, daysUntilWedding: daysUntilWedding)
        }

        // SCENARIO 2: Normal engagement (≤350 days out)
        return getTipForNormalEngagement(user: user, daysUntilWedding: daysUntilWedding)
    }

    // MARK: - Long Engagement Logic (>350 days)

    private func getTipForLongEngagement(user: User, daysUntilWedding: Int) -> Tip? {
        guard let initialDays = user.initialDaysUntilWedding, initialDays > 350 else {
            // Fallback if initialDaysUntilWedding not set
            return getRandomFunTip(excludeCategory: lastShownFunTipCategory)?.toTip()
        }

        // Calculate total days in "long engagement" phase
        // Example: 600 days wedding = 250 days in this phase (600 → 351)
        let totalLongEngagementDays = initialDays - 350
        let currentDayInPhase = initialDays - daysUntilWedding
        // currentDayInPhase: 0 = first day, increases as wedding approaches

        // We need to spread 50 critical tips across totalLongEngagementDays
        guard totalLongEngagementDays > 0 else {
            return getRandomFunTip(excludeCategory: lastShownFunTipCategory)?.toTip()
        }

        let tipsPerDay = 50.0 / Double(totalLongEngagementDays)
        let criticalTipIndex = Int(Double(currentDayInPhase) * tipsPerDay)

        // Check if today is a "critical tip day"
        // A day is critical if we've crossed into a new tip index
        let previousDayIndex = currentDayInPhase > 0 ? Int(Double(currentDayInPhase - 1) * tipsPerDay) : -1
        let isCriticalTipDay = criticalTipIndex > previousDayIndex && criticalTipIndex < 50

        if isCriticalTipDay && criticalTipIndex < criticalTips.count {
            // Show the critical tip
            let tip = criticalTips[criticalTipIndex]

            // Filter for tented wedding if applicable
            if !user.isTentedWedding && tip.weddingType == "tented" {
                // Skip tented-specific tips for non-tented weddings, show fun tip instead
                return getRandomFunTip(excludeCategory: lastShownFunTipCategory)?.toTip()
            }

            return tip
        }

        // Otherwise, show a fun tip
        return getRandomFunTip(excludeCategory: lastShownFunTipCategory)?.toTip()
    }

    // MARK: - Normal Engagement Logic (≤350 days)

    private func getTipForNormalEngagement(user: User, daysUntilWedding: Int) -> Tip? {
        // Get the master tip for this day using existing logic
        guard let masterTip = getMasterTipForDay(daysUntilWedding: daysUntilWedding, isTentedWedding: user.isTentedWedding) else {
            return nil
        }

        // If this tip is marked as fun_tip, pull a random fun tip instead
        if masterTip.funTip {
            return getRandomFunTip(excludeCategory: lastShownFunTipCategory)?.toTip() ?? masterTip
        }

        return masterTip
    }

    /// Original tip selection logic for normal engagements
    private func getMasterTipForDay(daysUntilWedding: Int, isTentedWedding: Bool) -> Tip? {
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

    // MARK: - Fun Tip Selection

    /// Get a random fun tip that hasn't been shown to the user
    private func getRandomFunTip(excludeCategory: String?) -> FunTip? {
        // Filter out already shown tips
        var availableTips = funTips.filter { !userShownFunTipIds.contains($0.id) }

        // Exclude last category to prevent back-to-back
        if let category = excludeCategory {
            let filtered = availableTips.filter { $0.category != category }
            if !filtered.isEmpty {
                availableTips = filtered
            }
            // If excluding category leaves no options, allow same category (just no exact repeats)
        }

        // If no tips available (all seen), we'd need to reset history
        // But since this is sync, we just return a random from all available
        if availableTips.isEmpty && !funTips.isEmpty {
            // All tips seen - return random from all (history should be reset async)
            return funTips.randomElement()
        }

        return availableTips.randomElement()
    }

    /// Record that a fun tip was shown (call this after displaying a fun tip)
    func recordFunTipShown(userId: UUID, funTip: FunTip, daysOut: Int) async {
        // Update local cache
        await MainActor.run {
            self.userShownFunTipIds.insert(funTip.id)
            self.lastShownFunTipCategory = funTip.category
        }

        // Persist to database
        do {
            try await supabase.recordFunTipShown(userId: userId, funTipId: funTip.id, daysOut: daysOut)
        } catch {
            print("Error recording fun tip shown: \(error)")
        }

        // Check if all fun tips have been shown
        if userShownFunTipIds.count >= funTips.count {
            await resetFunTipHistory(userId: userId)
        }
    }

    /// Reset fun tip history when all have been shown
    private func resetFunTipHistory(userId: UUID) async {
        do {
            try await supabase.resetFunTipHistory(userId: userId)
            await MainActor.run {
                self.userShownFunTipIds.removeAll()
                self.lastShownFunTipCategory = nil
            }
        } catch {
            print("Error resetting fun tip history: \(error)")
        }
    }

    // MARK: - Legacy Methods (kept for compatibility)

    /// Legacy method - use getTipForDay(user:daysUntilWedding:) instead
    func getTipForDay(daysUntilWedding: Int, isTentedWedding: Bool) -> Tip? {
        return getMasterTipForDay(daysUntilWedding: daysUntilWedding, isTentedWedding: isTentedWedding)
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
