import Foundation

enum Constants {
    // Supabase Configuration
    static let supabaseURL = "https://wntnnkdwghsoksoxlvhz.supabase.co"
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndudG5ua2R3Z2hzb2tzb3hsdmh6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYxNTUwOTcsImV4cCI6MjA4MTczMTA5N30.FJtQHbIdsjhscV_D6ULlYxSBk1LwxNQo5Lzc0RfXILU"

    // RevenueCat Configuration
    static let revenueCatAPIKey = "appl_XraWNcGtqqndhCbXJfaaoTvAJue"

    // Superwall Configuration
    static let superwallAPIKey = "pk_pICFw2H5SHJQ8NTA0zWkd"

    // Google Places Configuration
    static let googlePlacesAPIKey = "AIzaSyDAZOWGyD0HzLY9u1neQdV-JYTHjyCkSO4"

    // App Configuration
    static let freeTipLimit = 5  // Legacy - no longer used
    static let freeTrialDays = 3  // Days of free swiping before hard paywall
    static let freeUserMaxDaysBack = 7  // Free users can only see 7 days back from signup
    static let dailyNotificationHour = 9
    static let dailyNotificationMinute = 0

    // Superwall Events
    enum SuperwallEvents {
        static let onboardingComplete = "onboarding_complete"
        static let tipLimitReached = "tip_limit_reached"  // Legacy - no longer used
        static let freeTrialEnded = "free_trial_ended"  // Hard paywall after 3 days
        static let proBadgeTapped = "pro_badge_tapped"  // Crown icon on calendar
        static let swipeBackLimitReached = "swipe_back_limit_reached"  // Free user tried to swipe back past 7 days
        static let appOpen = "app_open"
        static let sessionStart = "session_start"
        static let featureLocked = "feature_locked"
        static let paywallDeclined = "paywall_declined"
    }

    // RevenueCat Entitlements
    enum Entitlements {
        static let premium = "Pro"
    }

    // User Defaults Keys
    enum UserDefaultsKeys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let currentUserId = "currentUserId"
        static let scheduledNotificationIds = "scheduledNotificationIds"
        static let firstAppOpenDate = "firstAppOpenDate"
        static let hasShownInstagramFollowPopup = "hasShownInstagramFollowPopup"
        static let lastViewedDate = "lastViewedDate"  // Date when calendar position was saved
        static let newDaysSwipedCount = "newDaysSwipedCount"  // Count of new days swiped
        static let hasRequestedRating = "hasRequestedRating"  // Whether we've asked for rating
    }

    // Social Links
    enum SocialLinks {
        static let instagramHandle = "thedailyido"
        static let instagramURL = "https://instagram.com/thedailyido"
    }

    // Notification Identifiers
    enum NotificationIdentifiers {
        static let dailyTip = "daily_tip"
        static let streakReminder = "streak_reminder"
    }

    // Colors (from Figma design)
    enum Colors {
        static let primaryText = "#1A1A2E"
        static let secondaryText = "#4C5C6B"
        static let accent = "#E8B4B8"
        static let buttonPrimary = "#4C5C6B"
        static let background = "#FEFEFE"
        static let cardBackground = "#FFFFFF"
        static let illustrationTint = "#4C5C6B"

        // Calendar specific colors
        static let calendarHeader = "#4C5C6B"
        static let calendarCard = "#FAF8F3"
        static let calendarBorder = "#E5E7EB"
        static let calendarTextPrimary = "#1E2939"
        static let calendarTextSecondary = "#364153"
        static let calendarTextTertiary = "#4A5565"
        static let calendarTextMuted = "#99A1AF"

        // Gold ring gradient colors
        static let goldLight = "#FFD230"
        static let goldMid = "#D08700"
        static let goldDark = "#BB4D00"

        // Tab bar colors
        static let tabActive = "#240115"
        static let tabInactive = "#99A1AF"
    }

    // Animation Durations
    enum Animation {
        static let tearDuration: Double = 0.4
        static let bounceSpring: Double = 0.6
        static let quickFade: Double = 0.2
    }

    // Tear Animation Parameters
    enum TearAnimation {
        // Thresholds
        static let snapThreshold: CGFloat = 120      // Point where perforations "break"
        static let completeThreshold: CGFloat = 200  // Point where tear completes
        static let velocityThreshold: CGFloat = 800  // Fast swipe auto-completes

        // Resistance phase (pre-snap)
        static let resistanceResponse: Double = 0.25
        static let resistanceDamping: Double = 0.9
        static let maxPreSnapRotation: Double = 8    // Degrees

        // Snap moment
        static let snapStiffness: Double = 500
        static let snapDamping: Double = 20
        static let snapScalePop: CGFloat = 1.02      // Brief scale increase

        // Tear release (post-snap)
        static let tearResponse: Double = 0.5
        static let tearDamping: Double = 0.75
        static let maxPostSnapRotation: Double = 35  // Degrees
        static let tearOffsetDistance: CGFloat = 500 // Off-screen distance

        // Cancel snap-back
        static let cancelResponse: Double = 0.35
        static let cancelDamping: Double = 0.7

        // Background card rise
        static let maxBackgroundRise: CGFloat = 10   // Points
        static let backgroundRiseResponse: Double = 0.4
        static let backgroundRiseDamping: Double = 0.85

        // Haptic timing
        static let resistanceHapticInterval: Double = 0.08  // Seconds between haptics
    }
}
