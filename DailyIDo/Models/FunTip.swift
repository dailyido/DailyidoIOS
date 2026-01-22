import Foundation

struct FunTip: Codable, Identifiable, Equatable {
    let id: UUID
    let title: String
    let tipText: String
    let hasIllustration: Bool
    let illustrationUrl: String?
    let category: String
    let priority: Int?  // Priority 1 fun tips shown first
    let affiliateUrl: String?
    let affiliateButtonText: String?
    let isActive: Bool
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case tipText = "tip_text"
        case hasIllustration = "has_illustration"
        case illustrationUrl = "illustration_url"
        case category
        case priority
        case affiliateUrl = "affiliate_url"
        case affiliateButtonText = "affiliate_button_text"
        case isActive = "is_active"
        case createdAt = "created_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        tipText = try container.decode(String.self, forKey: .tipText)
        hasIllustration = try container.decodeIfPresent(Bool.self, forKey: .hasIllustration) ?? false
        illustrationUrl = try container.decodeIfPresent(String.self, forKey: .illustrationUrl)
        // Default to "general" if category column doesn't exist
        category = try container.decodeIfPresent(String.self, forKey: .category) ?? "general"
        priority = try container.decodeIfPresent(Int.self, forKey: .priority)
        affiliateUrl = try container.decodeIfPresent(String.self, forKey: .affiliateUrl)
        affiliateButtonText = try container.decodeIfPresent(String.self, forKey: .affiliateButtonText)
        isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive) ?? true
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
    }

    init(id: UUID, title: String, tipText: String, hasIllustration: Bool, illustrationUrl: String?,
         category: String, priority: Int?, affiliateUrl: String?, affiliateButtonText: String?, isActive: Bool, createdAt: Date?) {
        self.id = id
        self.title = title
        self.tipText = tipText
        self.hasIllustration = hasIllustration
        self.illustrationUrl = illustrationUrl
        self.category = category
        self.priority = priority
        self.affiliateUrl = affiliateUrl
        self.affiliateButtonText = affiliateButtonText
        self.isActive = isActive
        self.createdAt = createdAt
    }

    var fullIllustrationUrl: String? {
        guard let illustrationUrl = illustrationUrl, hasIllustration else { return nil }
        let encodedFilename = illustrationUrl.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? illustrationUrl
        return "\(Constants.supabaseURL)/storage/v1/object/public/illustrations/\(encodedFilename)"
    }

    static func == (lhs: FunTip, rhs: FunTip) -> Bool {
        lhs.id == rhs.id
    }

    /// Convert FunTip to Tip for display compatibility
    func toTip() -> Tip {
        Tip(
            id: id,
            title: title,
            tipText: tipText,
            hasIllustration: hasIllustration,
            illustrationUrl: illustrationUrl,
            category: category,
            monthCategory: nil,
            specificDay: nil,
            priority: 0,
            onChecklist: false,
            affiliateUrl: affiliateUrl,
            affiliateButtonText: affiliateButtonText,
            weddingType: nil,
            isActive: isActive,
            funTip: true,
            createdAt: createdAt
        )
    }
}

/// Categories for fun tips
enum FunTipCategory: String, CaseIterable {
    case trivia
    case dateNight = "date_night"
    case relationship
    case conversation
    case selfCare = "self_care"
    case activity
    case inspiration
}

/// Tracks which fun tips a user has seen
struct UserFunTipShown: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let funTipId: UUID
    let shownAt: Date?
    let shownOnDay: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case funTipId = "fun_tip_id"
        case shownAt = "shown_at"
        case shownOnDay = "shown_on_day"
    }
}
