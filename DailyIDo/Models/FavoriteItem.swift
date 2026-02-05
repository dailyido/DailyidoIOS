import Foundation

struct FavoriteItem: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let tipId: UUID
    let favoritedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case tipId = "tip_id"
        case favoritedAt = "favorited_at"
    }

    init(id: UUID = UUID(), userId: UUID, tipId: UUID, favoritedAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.tipId = tipId
        self.favoritedAt = favoritedAt
    }
}
