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
}
