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
