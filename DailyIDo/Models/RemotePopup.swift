import Foundation

struct RemotePopup: Codable, Identifiable {
    let id: UUID
    let popupType: String
    let triggerDate: Date?
    let triggerDaysOut: Int?
    let title: String
    let message: String
    let imageUrl: String?
    let illustrationUrl: String?
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
        case illustrationUrl = "illustration_url"
        case ctaText = "cta_text"
        case ctaAction = "cta_action"
        case isActive = "is_active"
    }

    /// Full URL for the illustration from the holiday_popups storage bucket
    var fullIllustrationUrl: String? {
        guard let illustrationUrl = illustrationUrl, !illustrationUrl.isEmpty else { return nil }
        let encodedFilename = illustrationUrl.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? illustrationUrl
        return "\(Constants.supabaseURL)/storage/v1/object/public/holiday_popups/\(encodedFilename)"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        popupType = try container.decode(String.self, forKey: .popupType)
        triggerDaysOut = try container.decodeIfPresent(Int.self, forKey: .triggerDaysOut)
        title = try container.decode(String.self, forKey: .title)
        message = try container.decode(String.self, forKey: .message)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        illustrationUrl = try container.decodeIfPresent(String.self, forKey: .illustrationUrl)
        ctaText = try container.decodeIfPresent(String.self, forKey: .ctaText)
        ctaAction = try container.decodeIfPresent(String.self, forKey: .ctaAction)
        isActive = try container.decode(Bool.self, forKey: .isActive)

        // Handle trigger_date which comes as "YYYY-MM-DD" string from Supabase
        if let dateString = try container.decodeIfPresent(String.self, forKey: .triggerDate) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone.current
            triggerDate = formatter.date(from: dateString)
        } else {
            triggerDate = nil
        }
    }

    // For previews and testing
    init(id: UUID, popupType: String, triggerDate: Date?, triggerDaysOut: Int?, title: String, message: String, imageUrl: String?, illustrationUrl: String? = nil, ctaText: String?, ctaAction: String?, isActive: Bool) {
        self.id = id
        self.popupType = popupType
        self.triggerDate = triggerDate
        self.triggerDaysOut = triggerDaysOut
        self.title = title
        self.message = message
        self.imageUrl = imageUrl
        self.illustrationUrl = illustrationUrl
        self.ctaText = ctaText
        self.ctaAction = ctaAction
        self.isActive = isActive
    }
}

enum PopupType: String {
    case holiday
    case daysOut = "days_out"
    case custom
}
