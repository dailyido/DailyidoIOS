import Foundation
import UIKit

// MARK: - Analytics Event Names

enum AnalyticsEvent: String {
    // Onboarding
    case onboardingStarted = "onboarding_started"
    case onboardingScreenViewed = "onboarding_screen_viewed"
    case onboardingScreenCompleted = "onboarding_screen_completed"
    case onboardingCompleted = "onboarding_completed"
    case onboardingAbandoned = "onboarding_abandoned"

    // App Lifecycle
    case appOpened = "app_opened"
    case appClosed = "app_closed"
    case appBackgrounded = "app_backgrounded"
    case appForegrounded = "app_foregrounded"

    // Engagement
    case tipViewed = "tip_viewed"
    case checklistItemCompleted = "checklist_item_completed"
    case checklistItemUncompleted = "checklist_item_uncompleted"
    case calendarSwiped = "calendar_swiped"
    case checklistTabOpened = "checklist_tab_opened"
    case calendarTabOpened = "calendar_tab_opened"
    case settingsOpened = "settings_opened"
    case shareTapped = "share_tapped"
    case reminderTapped = "reminder_tapped"
    case affiliateLinkTapped = "affiliate_link_tapped"

    // Streaks
    case streakUpdated = "streak_updated"
    case streakMilestoneHit = "streak_milestone_hit"
    case streakBroken = "streak_broken"

    // Settings
    case profileUpdated = "profile_updated"
    case shareAppTapped = "share_app_tapped"
    case restorePurchasesTapped = "restore_purchases_tapped"
    case couplePhotoUpdated = "couple_photo_updated"
    case meetThePlannersOpened = "meet_the_planners_opened"

    // Retention
    case day1Return = "day_1_return"
    case day7Return = "day_7_return"
    case day30Return = "day_30_return"

    // Errors
    case errorOccurred = "error_occurred"
}

// MARK: - Onboarding Screen Names

enum OnboardingScreen: String {
    case intro = "intro"
    case welcome = "welcome"
    case yourName = "your_name"
    case partnerName = "partner_name"
    case couplePhoto = "couple_photo"
    case weddingDate = "wedding_date"
    case weddingLocation = "wedding_location"
    case tentedQuestion = "tented_question"
    case referralSource = "referral_source"
    case notificationsPermission = "notifications_permission"
    case preparedness = "preparedness"
    case ratingRequest = "rating_request"
    case loading = "loading"
    case planReveal = "plan_reveal"
    case longEngagementTutorial = "long_engagement_tutorial"

    /// Convert onboarding step number to screen enum
    static func fromStep(_ step: Int) -> OnboardingScreen? {
        switch step {
        case 0: return .intro
        case 1: return .welcome
        case 2: return .yourName
        case 3: return .partnerName
        case 4: return .couplePhoto
        case 5: return .weddingDate
        case 6: return .weddingLocation
        case 7: return .tentedQuestion
        case 8: return .referralSource
        case 9: return .notificationsPermission
        case 10: return .preparedness
        case 11: return .ratingRequest
        case 12: return .loading
        case 13: return .planReveal
        case 14: return .longEngagementTutorial
        default: return nil
        }
    }
}

// MARK: - Analytics Service

final class AnalyticsService {
    static let shared = AnalyticsService()

    private var sessionId: UUID = UUID()
    private var sessionStart: Date = Date()
    private var isEnabled: Bool = true
    private let supabase = SupabaseService.shared

    private init() {}

    // MARK: - Session Management

    func startSession() {
        sessionId = UUID()
        sessionStart = Date()
        log(.appOpened)
        checkRetentionMilestones()
    }

    func endSession() {
        let duration = Date().timeIntervalSince(sessionStart)
        log(.appClosed, data: ["session_duration_seconds": Int(duration)])
    }

    func appBackgrounded() {
        let duration = Date().timeIntervalSince(sessionStart)
        log(.appBackgrounded, data: ["session_duration_seconds": Int(duration)])
    }

    func appForegrounded() {
        log(.appForegrounded)
    }

    // MARK: - Core Logging

    func log(_ event: AnalyticsEvent, data: [String: Any] = [:], screenName: String? = nil) {
        guard isEnabled else { return }

        Task {
            await logAsync(event, data: data, screenName: screenName)
        }
    }

    private func logAsync(_ event: AnalyticsEvent, data: [String: Any], screenName: String?) async {
        do {
            // Convert data dictionary to JSON-compatible format
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"

            let eventRecord = AnalyticsEventRecord(
                userId: AuthService.shared.currentUser?.id,
                eventName: event.rawValue,
                eventData: jsonString,
                screenName: screenName,
                sessionId: sessionId,
                deviceType: UIDevice.current.model,
                osVersion: UIDevice.current.systemVersion,
                appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
            )

            try await supabase.client
                .from("analytics_events")
                .insert(eventRecord)
                .execute()

            #if DEBUG
            print("📊 Analytics: \(event.rawValue) \(data.isEmpty ? "" : "- \(data)")")
            #endif
        } catch {
            print("Analytics error: \(error)")
        }
    }

    // MARK: - Onboarding Tracking

    func logOnboardingStarted() {
        log(.onboardingStarted)
    }

    func logOnboardingScreen(_ screen: OnboardingScreen) {
        log(.onboardingScreenViewed, screenName: screen.rawValue)
    }

    func logOnboardingScreenCompleted(_ screen: OnboardingScreen) {
        log(.onboardingScreenCompleted, screenName: screen.rawValue)
    }

    func logOnboardingCompleted() {
        log(.onboardingCompleted)
    }

    func logOnboardingAbandoned(atScreen screen: OnboardingScreen) {
        log(.onboardingAbandoned, data: ["last_screen": screen.rawValue])
    }

    // MARK: - Engagement Tracking

    func logTipViewed(tipId: UUID, dayNumber: Int, isFunTip: Bool) {
        log(.tipViewed, data: [
            "tip_id": tipId.uuidString,
            "day_number": dayNumber,
            "is_fun_tip": isFunTip
        ])
    }

    func logChecklistCompleted(tipId: UUID) {
        log(.checklistItemCompleted, data: ["tip_id": tipId.uuidString])
    }

    func logChecklistUncompleted(tipId: UUID) {
        log(.checklistItemUncompleted, data: ["tip_id": tipId.uuidString])
    }

    func logCalendarSwiped(direction: String, fromDay: Int, toDay: Int) {
        log(.calendarSwiped, data: [
            "direction": direction,
            "from_day": fromDay,
            "to_day": toDay
        ])
    }

    func logTabOpened(_ tab: String) {
        switch tab {
        case "calendar":
            log(.calendarTabOpened)
        case "checklist":
            log(.checklistTabOpened)
        default:
            break
        }
    }

    func logSettingsOpened() {
        log(.settingsOpened)
    }

    func logShareTapped(tipId: UUID, platform: String) {
        log(.shareTapped, data: [
            "tip_id": tipId.uuidString,
            "platform": platform
        ])
    }

    func logReminderTapped(tipId: UUID) {
        log(.reminderTapped, data: ["tip_id": tipId.uuidString])
    }

    func logAffiliateLinkTapped(tipId: UUID, url: String) {
        log(.affiliateLinkTapped, data: [
            "tip_id": tipId.uuidString,
            "url": url
        ])
    }

    // MARK: - Streak Tracking

    func logStreakUpdated(current: Int, longest: Int) {
        log(.streakUpdated, data: [
            "current_streak": current,
            "longest_streak": longest
        ])
    }

    func logStreakMilestone(_ days: Int) {
        log(.streakMilestoneHit, data: ["milestone_days": days])
    }

    func logStreakBroken(previousStreak: Int) {
        log(.streakBroken, data: ["previous_streak": previousStreak])
    }

    // MARK: - Settings Tracking

    func logProfileUpdated() {
        log(.profileUpdated)
    }

    func logShareAppTapped() {
        log(.shareAppTapped, data: ["source": "settings"])
    }

    func logRestorePurchasesTapped() {
        log(.restorePurchasesTapped)
    }

    func logCouplePhotoUpdated() {
        log(.couplePhotoUpdated)
    }

    func logMeetThePlannersOpened() {
        log(.meetThePlannersOpened)
    }

    // MARK: - Retention Tracking

    private func checkRetentionMilestones() {
        guard let user = AuthService.shared.currentUser,
              let createdAt = user.createdAt else { return }

        let daysSinceSignup = Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 0

        // Check if we should log retention events
        let key = "retention_logged_day_\(daysSinceSignup)"
        if !UserDefaults.standard.bool(forKey: key) {
            switch daysSinceSignup {
            case 1:
                log(.day1Return)
                UserDefaults.standard.set(true, forKey: key)
            case 7:
                log(.day7Return)
                UserDefaults.standard.set(true, forKey: key)
            case 30:
                log(.day30Return)
                UserDefaults.standard.set(true, forKey: key)
            default:
                break
            }
        }
    }

    // MARK: - Error Tracking

    func logError(_ error: Error, context: String) {
        log(.errorOccurred, data: [
            "error_message": error.localizedDescription,
            "context": context
        ])
    }

    // MARK: - Settings

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
    }
}

// MARK: - Analytics Event Record (for Supabase insert)

private struct AnalyticsEventRecord: Encodable {
    let userId: UUID?
    let eventName: String
    let eventData: String  // JSON string
    let screenName: String?
    let sessionId: UUID
    let deviceType: String
    let osVersion: String
    let appVersion: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case eventName = "event_name"
        case eventData = "event_data"
        case screenName = "screen_name"
        case sessionId = "session_id"
        case deviceType = "device_type"
        case osVersion = "os_version"
        case appVersion = "app_version"
    }
}
