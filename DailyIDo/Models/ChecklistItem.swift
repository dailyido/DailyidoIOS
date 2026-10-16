import Foundation

struct ChecklistItem: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let tipId: UUID
    let completedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case tipId = "tip_id"
        case completedAt = "completed_at"
    }
}

struct ChecklistDisplayItem: Identifiable {
    let tip: Tip
    var isCompleted: Bool
    var completedAt: Date?

    var id: UUID { tip.id }
}

/// A to-do written by the user and attached to a checklist timeframe section.
/// `monthCategory` matches the MonthCategory rawValues (e.g. "12+ months").
struct UserTodo: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    var title: String
    var note: String?
    var monthCategory: String
    var completedAt: Date?
    let createdAt: Date

    var isCompleted: Bool { completedAt != nil }

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case note
        case monthCategory = "month_category"
        case completedAt = "completed_at"
        case createdAt = "created_at"
    }
}
