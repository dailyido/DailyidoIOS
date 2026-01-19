import Foundation

struct Tip: Codable, Identifiable, Equatable {
    let id: UUID
    let title: String
    let tipText: String
    let hasIllustration: Bool
    let illustrationUrl: String?
    let monthCategory: String?
    let specificDay: Int?
    let priority: Int
    let onChecklist: Bool
    let affiliateUrl: String?
    let affiliateButtonText: String?
    let weddingType: String?
    let isActive: Bool
    let funTip: Bool
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case tipText = "tip_text"
        case hasIllustration = "has_illustration"
        case illustrationUrl = "illustration_url"
        case monthCategory = "month_category"
        case specificDay = "specific_day"
        case priority
        case onChecklist = "on_checklist"
        case affiliateUrl = "affiliate_url"
        case affiliateButtonText = "affiliate_button_text"
        case weddingType = "wedding_type"
        case isActive = "is_active"
        case funTip = "fun_tip"
        case createdAt = "created_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        tipText = try container.decode(String.self, forKey: .tipText)
        hasIllustration = try container.decode(Bool.self, forKey: .hasIllustration)
        illustrationUrl = try container.decodeIfPresent(String.self, forKey: .illustrationUrl)
        monthCategory = try container.decodeIfPresent(String.self, forKey: .monthCategory)
        specificDay = try container.decodeIfPresent(Int.self, forKey: .specificDay)
        priority = try container.decode(Int.self, forKey: .priority)
        onChecklist = try container.decode(Bool.self, forKey: .onChecklist)
        affiliateUrl = try container.decodeIfPresent(String.self, forKey: .affiliateUrl)
        affiliateButtonText = try container.decodeIfPresent(String.self, forKey: .affiliateButtonText)
        weddingType = try container.decodeIfPresent(String.self, forKey: .weddingType)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        // Default to false if fun_tip column doesn't exist in database yet
        funTip = try container.decodeIfPresent(Bool.self, forKey: .funTip) ?? false
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
    }

    init(id: UUID, title: String, tipText: String, hasIllustration: Bool, illustrationUrl: String?,
         monthCategory: String?, specificDay: Int?, priority: Int, onChecklist: Bool,
         affiliateUrl: String?, affiliateButtonText: String?, weddingType: String?,
         isActive: Bool, funTip: Bool, createdAt: Date?) {
        self.id = id
        self.title = title
        self.tipText = tipText
        self.hasIllustration = hasIllustration
        self.illustrationUrl = illustrationUrl
        self.monthCategory = monthCategory
        self.specificDay = specificDay
        self.priority = priority
        self.onChecklist = onChecklist
        self.affiliateUrl = affiliateUrl
        self.affiliateButtonText = affiliateButtonText
        self.weddingType = weddingType
        self.isActive = isActive
        self.funTip = funTip
        self.createdAt = createdAt
    }

    var fullIllustrationUrl: String? {
        guard let illustrationUrl = illustrationUrl, hasIllustration else { return nil }
        // URL-encode the filename to handle spaces and special characters
        let encodedFilename = illustrationUrl.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? illustrationUrl
        return "\(Constants.supabaseURL)/storage/v1/object/public/illustrations/\(encodedFilename)"
    }

    static func == (lhs: Tip, rhs: Tip) -> Bool {
        lhs.id == rhs.id
    }
}

enum MonthCategory: String, CaseIterable {
    case twelveMonthsPlus = "12+ months"
    case nineToTwelveMonths = "9-12 months"
    case sixToNineMonths = "6-9 months"
    case threeToSixMonths = "3-6 months"
    case oneToThreeMonths = "1-3 months"
    case finalMonth = "Final month"
    case weddingWeek = "Wedding week"

    static func category(forDaysOut days: Int) -> MonthCategory {
        switch days {
        case 365...: return .twelveMonthsPlus
        case 270..<365: return .nineToTwelveMonths
        case 180..<270: return .sixToNineMonths
        case 90..<180: return .threeToSixMonths
        case 30..<90: return .oneToThreeMonths
        case 8..<30: return .finalMonth
        default: return .weddingWeek
        }
    }

    var displayOrder: Int {
        switch self {
        case .twelveMonthsPlus: return 0
        case .nineToTwelveMonths: return 1
        case .sixToNineMonths: return 2
        case .threeToSixMonths: return 3
        case .oneToThreeMonths: return 4
        case .finalMonth: return 5
        case .weddingWeek: return 6
        }
    }
}
