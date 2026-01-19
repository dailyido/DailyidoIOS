import Foundation
import Supabase

final class SupabaseService {
    static let shared = SupabaseService()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: Constants.supabaseURL)!,
            supabaseKey: Constants.supabaseAnonKey
        )
    }

    // MARK: - User Operations

    func fetchUser(id: UUID) async throws -> User? {
        let response: User? = try await client
            .from("users")
            .select()
            .eq("id", value: id.uuidString)
            .single()
            .execute()
            .value

        return response
    }

    func createUser(_ user: User) async throws {
        try await client
            .from("users")
            .upsert(user)
            .execute()
        print("✅ [Supabase] User upserted: \(user.id)")
    }

    func updateUser(_ user: User) async throws {
        try await client
            .from("users")
            .upsert(user)
            .execute()
    }

    // MARK: - Tips Operations

    func fetchAllTips() async throws -> [Tip] {
        let response: [Tip] = try await client
            .from("wedding_tips")
            .select()
            .eq("is_active", value: true)
            .execute()
            .value

        return response
    }

    func fetchTipsForChecklist() async throws -> [Tip] {
        let response: [Tip] = try await client
            .from("wedding_tips")
            .select()
            .eq("is_active", value: true)
            .eq("on_checklist", value: true)
            .order("priority", ascending: true)
            .execute()
            .value

        return response
    }

    // MARK: - Checklist Operations

    func fetchUserChecklist(userId: UUID) async throws -> [ChecklistItem] {
        let response: [ChecklistItem] = try await client
            .from("user_checklist")
            .select()
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value

        return response
    }

    func addChecklistItem(userId: UUID, tipId: UUID) async throws {
        let item = ChecklistItem(
            id: UUID(),
            userId: userId,
            tipId: tipId,
            completedAt: Date()
        )

        try await client
            .from("user_checklist")
            .insert(item)
            .execute()
    }

    func removeChecklistItem(userId: UUID, tipId: UUID) async throws {
        try await client
            .from("user_checklist")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .eq("tip_id", value: tipId.uuidString)
            .execute()
    }

    // MARK: - Remote Popups

    func fetchActivePopups() async throws -> [RemotePopup] {
        let response: [RemotePopup] = try await client
            .from("remote_popups")
            .select()
            .eq("is_active", value: true)
            .execute()
            .value

        return response
    }

    // MARK: - App Config

    func fetchAppConfig(key: String) async throws -> AppConfig? {
        let response: AppConfig? = try await client
            .from("app_config")
            .select()
            .eq("config_key", value: key)
            .eq("is_active", value: true)
            .single()
            .execute()
            .value

        return response
    }

    func fetchStreakMilestones() async throws -> [StreakMilestone] {
        guard let config = try await fetchAppConfig(key: "streak_milestones"),
              let milestones = config.configValue.milestones else {
            return []
        }
        return milestones
    }

    // MARK: - Scheduled Notifications

    func fetchScheduledNotifications() async throws -> [ScheduledNotification] {
        let response: [ScheduledNotification] = try await client
            .from("scheduled_notifications")
            .select()
            .eq("is_active", value: true)
            .execute()
            .value

        return response
    }

    // MARK: - Fun Tips Operations

    func fetchAllFunTips() async throws -> [FunTip] {
        let response: [FunTip] = try await client
            .from("fun_tips")
            .select()
            .eq("is_active", value: true)
            .execute()
            .value

        return response
    }

    func fetchFunTipsExcluding(ids: [UUID], excludeCategory: String?) async throws -> [FunTip] {
        var query = client
            .from("fun_tips")
            .select()
            .eq("is_active", value: true)

        // Note: Supabase Swift doesn't have a direct "not in" operator,
        // so we'll filter in memory after fetching
        let response: [FunTip] = try await query.execute().value

        return response.filter { tip in
            let notInExcludedIds = !ids.contains(tip.id)
            let notInExcludedCategory = excludeCategory == nil || tip.category != excludeCategory
            return notInExcludedIds && notInExcludedCategory
        }
    }

    func fetchUserShownFunTipIds(userId: UUID) async throws -> [UUID] {
        let response: [UserFunTipShown] = try await client
            .from("user_fun_tips_shown")
            .select()
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value

        return response.map { $0.funTipId }
    }

    func fetchLastShownFunTipCategory(userId: UUID) async throws -> String? {
        struct FunTipJoin: Codable {
            let funTipId: UUID
            let category: String?

            enum CodingKeys: String, CodingKey {
                case funTipId = "fun_tip_id"
                case category
            }
        }

        // Fetch the most recent shown fun tip with its category
        let response: [UserFunTipShown] = try await client
            .from("user_fun_tips_shown")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("shown_at", ascending: false)
            .limit(1)
            .execute()
            .value

        guard let lastShown = response.first else { return nil }

        // Fetch the fun tip to get its category
        let funTip: FunTip? = try await client
            .from("fun_tips")
            .select()
            .eq("id", value: lastShown.funTipId.uuidString)
            .single()
            .execute()
            .value

        return funTip?.category
    }

    func recordFunTipShown(userId: UUID, funTipId: UUID, daysOut: Int) async throws {
        let record = UserFunTipShown(
            id: UUID(),
            userId: userId,
            funTipId: funTipId,
            shownAt: Date(),
            shownOnDay: daysOut
        )

        try await client
            .from("user_fun_tips_shown")
            .upsert(record)
            .execute()
    }

    func resetFunTipHistory(userId: UUID) async throws {
        try await client
            .from("user_fun_tips_shown")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .execute()
    }

    func fetchFirst50CriticalTips() async throws -> [Tip] {
        let response: [Tip] = try await client
            .from("wedding_tips")
            .select()
            .eq("is_active", value: true)
            .order("priority", ascending: true)
            .limit(50)
            .execute()
            .value

        return response
    }
}
