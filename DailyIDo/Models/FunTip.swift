import Foundation

struct FunTip: Codable, Identifiable, Equatable {
    let id: UUID
    let title: String
    let tipText: String
    let hasIllustration: Bool
    let illustrationUrl: String?
    let category: String
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
        case affiliateUrl = "affiliate_url"
        case affiliateButtonText = "affiliate_button_text"
        case isActive = "is_active"
        case createdAt = "created_at"
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
