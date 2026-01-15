import Foundation

struct AppConfig: Codable, Identifiable {
    let id: UUID
    let configKey: String
    let configValue: ConfigValue
    let isActive: Bool
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case configKey = "config_key"
        case configValue = "config_value"
        case isActive = "is_active"
        case updatedAt = "updated_at"
    }
}

struct ConfigValue: Codable {
    let milestones: [StreakMilestone]?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let milestoneData = try? container.decode([StreakMilestone].self) {
            self.milestones = milestoneData
        } else {
            self.milestones = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(milestones)
    }
}

struct StreakMilestone: Codable, Identifiable {
    var id: Int { days }
    let days: Int
    let title: String
    let message: String
}

struct ScheduledNotification: Codable, Identifiable {
    let id: UUID
    let title: String
    let body: String
    let triggerType: String
    let triggerDate: Date?
    let triggerDays: Int?
    let isActive: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case body
        case triggerType = "trigger_type"
        case triggerDate = "trigger_date"
        case triggerDays = "trigger_days"
        case isActive = "is_active"
    }
}

enum NotificationTriggerType: String {
    case date
    case daysOut = "days_out"
    case daysAfterSignup = "days_after_signup"
}
