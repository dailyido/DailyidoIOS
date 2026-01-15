import Foundation

struct RemotePopup: Codable, Identifiable {
    let id: UUID
    let popupType: String
    let triggerDate: Date?
    let triggerDaysOut: Int?
    let title: String
    let message: String
    let imageUrl: String?
    let ctaText: String?
    let ctaAction: String?
    let isActive: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case popupType = "popup_type"
        case triggerDate = "trigger_date"
        case triggerDaysOut = "trigger_days_out"
        case title
        case message
        case imageUrl = "image_url"
        case ctaText = "cta_text"
        case ctaAction = "cta_action"
        case isActive = "is_active"
    }
}

enum PopupType: String {
    case holiday
    case daysOut = "days_out"
    case custom
}
