import SwiftUI

@main
struct DailyIDoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authService = AuthService.shared
    @State private var isOnboardingComplete = false

    var body: some Scene {
        WindowGroup {
            Group {
                if authService.isLoading {
                    LaunchScreenView()
                } else if !authService.isAuthenticated || !(authService.currentUser?.onboardingComplete ?? false) {
                    OnboardingContainerView(isOnboardingComplete: $isOnboardingComplete)
                        .onChange(of: isOnboardingComplete) { newValue in
                            if newValue {
                                Task {
                                    try? await authService.refreshUser()
                                }
                            }
                        }
                } else {
                    MainTabView()
                        .onAppear {
                            // Identify existing user in RevenueCat with their attributes
                            if let user = authService.currentUser {
                                SubscriptionService.shared.identifyUser(userId: user.id.uuidString)
                                SubscriptionService.shared.setUserAttributes(
                                    name: user.name,
                                    partnerName: user.partnerName,
                                    weddingDate: user.weddingDate,
                                    weddingVenue: user.weddingVenue
                                )
                            }
                        }
                }
            }
            .preferredColorScheme(.light)
        }
    }
}

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            Color(hex: Constants.Colors.background)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color(hex: Constants.Colors.accent).opacity(0.15))
                        .frame(width: 120, height: 120)

                    Image(systemName: "heart.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Color(hex: Constants.Colors.accent))
                }

                Text("Daily I Do")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(hex: Constants.Colors.primaryText))

                LoadingSpinner()
                    .padding(.top, 20)
            }
        }
    }
}

struct MainTabView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab = 0
    @StateObject private var streakService = StreakService.shared
    @State private var showRemotePopup = false
    @State private var currentPopup: RemotePopup?
    @State private var couplePhoto: UIImage? = OnboardingViewModel.loadCouplePhoto()
    @State private var showTutorial = false
    @State private var showInstagramPopup = false

    // Check if tutorial should show
    private var shouldShowTutorial: Bool {
        !UserDefaults.standard.bool(forKey: "hasSeenTutorial")
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Content
                Group {
                    switch selectedTab {
                    case 0:
                        CalendarView(isTutorialShowing: $showTutorial)
                    case 1:
                        ChecklistView()
                    case 2:
                        SettingsView(onDone: {
                            selectedTab = 0
                        }, onRestartTutorial: {
                            selectedTab = 0
                            showTutorial = true
                        })
                    default:
                        CalendarView(isTutorialShowing: $showTutorial)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Custom Tab Bar
                CustomTabBar(selectedTab: $selectedTab, couplePhoto: couplePhoto)
            }
            .ignoresSafeArea(.keyboard)
            .onChange(of: selectedTab) { newTab in
                // Refresh photo when leaving settings tab
                if newTab != 2 {
                    couplePhoto = OnboardingViewModel.loadCouplePhoto()
                }

                // Track tab opens
                switch newTab {
                case 0:
                    AnalyticsService.shared.logTabOpened("calendar")
                case 1:
                    AnalyticsService.shared.logTabOpened("checklist")
                case 2:
                    AnalyticsService.shared.logSettingsOpened()
                default:
                    break
                }
            }

            // Streak celebration overlay
            if let milestone = streakService.showingMilestone {
                CelebrationPopup(milestone: milestone) {
                    streakService.dismissMilestone()
                }
            }

            // Tutorial overlay - FULL SCREEN covering everything including tab bar
            if showTutorial {
                TutorialView(isPresented: $showTutorial)
            }

            // Remote popup overlay
            if showRemotePopup, let popup = currentPopup {
                RemotePopupView(
                    popup: popup,
                    onDismiss: {
                        showRemotePopup = false
                        currentPopup = nil
                    },
                    onCTATap: {
                        if let action = popup.ctaAction, let url = URL(string: action) {
                            UIApplication.shared.open(url)
                        }
                    }
                )
            }

            // Instagram follow popup (5 days after first use)
            if showInstagramPopup {
                RemotePopupView(
                    popup: RemotePopup(
                        id: UUID(),
                        popupType: "custom",
                        triggerDate: nil,
                        triggerDaysOut: nil,
                        title: "Join Our Community!",
                        message: "Follow us on Instagram for wedding inspiration, planning tips, and behind-the-scenes moments from real weddings!",
                        imageUrl: nil,
                        illustrationUrl: nil,
                        ctaText: "Follow @thedailyido",
                        ctaAction: Constants.SocialLinks.instagramURL,
                        isActive: true
                    ),
                    onDismiss: {
                        showInstagramPopup = false
                        UserDefaults.standard.set(true, forKey: Constants.UserDefaultsKeys.hasShownInstagramFollowPopup)
                    },
                    onCTATap: {
                        if let url = URL(string: Constants.SocialLinks.instagramURL) {
                            UIApplication.shared.open(url)
                        }
                        UserDefaults.standard.set(true, forKey: Constants.UserDefaultsKeys.hasShownInstagramFollowPopup)
                    }
                )
            }
        }
        .task {
            // Show tutorial immediately for first-time users
            if shouldShowTutorial {
                showTutorial = true
            }

            trackFirstAppOpen()
            await checkForRemotePopups()
            checkForInstagramFollowPopup()
        }
        // Handle app becoming active
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                // Reset streak reminder to tomorrow (so today's doesn't fire if user opened app)
                NotificationService.shared.resetStreakReminderForTomorrow()

                Task {
                    await checkForRemotePopups()
                }
            }
        }
    }

    /// Check if this popup was already shown today
    private func hasShownPopupToday(_ popupId: UUID) -> Bool {
        let key = "popup_shown_\(popupId.uuidString)"
        guard let lastShown = UserDefaults.standard.object(forKey: key) as? Date else {
            return false
        }
        return Calendar.current.isDateInToday(lastShown)
    }

    /// Mark a popup as shown today
    private func markPopupShownToday(_ popupId: UUID) {
        let key = "popup_shown_\(popupId.uuidString)"
        UserDefaults.standard.set(Date(), forKey: key)
    }

    private func checkForRemotePopups() async {
        // Don't show popups until user has completed the tutorial
        guard UserDefaults.standard.bool(forKey: "hasSeenTutorial") else {
            print("DEBUG: Tutorial not yet completed, skipping remote popups")
            return
        }

        guard let user = AuthService.shared.currentUser,
              let weddingDate = user.weddingDate else {
            print("DEBUG: No user or wedding date")
            return
        }

        let daysOut = Date().daysUntil(weddingDate)
        let today = Date()

        do {
            let popups = try await SupabaseService.shared.fetchActivePopups()
            print("DEBUG: Fetched \(popups.count) popups")

            for popup in popups {
                print("DEBUG: Popup - type: \(popup.popupType), triggerDate: \(String(describing: popup.triggerDate)), title: \(popup.title)")
                if let triggerDate = popup.triggerDate {
                    print("DEBUG: Comparing triggerDate \(triggerDate) with today \(today)")
                    print("DEBUG: Same day? \(Calendar.current.isDate(triggerDate, inSameDayAs: today))")
                }
            }

            // Check for holiday popup (date-based)
            if let holidayPopup = popups.first(where: {
                $0.popupType == PopupType.holiday.rawValue &&
                $0.triggerDate != nil &&
                Calendar.current.isDate($0.triggerDate!, inSameDayAs: today)
            }) {
                guard !hasShownPopupToday(holidayPopup.id) else {
                    print("DEBUG: Holiday popup already shown today, skipping")
                    return
                }
                print("DEBUG: Found matching holiday popup!")
                await MainActor.run {
                    currentPopup = holidayPopup
                    showRemotePopup = true
                    markPopupShownToday(holidayPopup.id)
                }
                return
            }

            // Check for days_out popup (milestone like "30 days!")
            if let daysOutPopup = popups.first(where: {
                $0.popupType == PopupType.daysOut.rawValue &&
                $0.triggerDaysOut == daysOut
            }) {
                guard !hasShownPopupToday(daysOutPopup.id) else {
                    print("DEBUG: Days-out popup already shown today, skipping")
                    return
                }
                print("DEBUG: Found matching days_out popup!")
                await MainActor.run {
                    currentPopup = daysOutPopup
                    showRemotePopup = true
                    markPopupShownToday(daysOutPopup.id)
                }
            }
        } catch {
            print("DEBUG Error fetching remote popups: \(error)")
        }
    }

    /// Track the first time the user opens the app
    private func trackFirstAppOpen() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: Constants.UserDefaultsKeys.firstAppOpenDate) == nil {
            defaults.set(Date(), forKey: Constants.UserDefaultsKeys.firstAppOpenDate)
            print("DEBUG: First app open tracked at \(Date())")
        }
    }

    /// Check if we should show the Instagram follow popup (5 days after first use)
    private func checkForInstagramFollowPopup() {
        let defaults = UserDefaults.standard

        // Don't show until tutorial is completed
        guard defaults.bool(forKey: "hasSeenTutorial") else {
            return
        }

        // Don't show if already shown
        if defaults.bool(forKey: Constants.UserDefaultsKeys.hasShownInstagramFollowPopup) {
            return
        }

        // Check if first open date exists and 5 days have passed
        guard let firstOpenDate = defaults.object(forKey: Constants.UserDefaultsKeys.firstAppOpenDate) as? Date else {
            return
        }

        let daysSinceFirstOpen = Calendar.current.dateComponents([.day], from: firstOpenDate, to: Date()).day ?? 0

        if daysSinceFirstOpen >= 5 {
            // Small delay to not conflict with other popups
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                // Only show if no other popup is showing
                if !showRemotePopup && streakService.showingMilestone == nil {
                    showInstagramPopup = true
                }
            }
        }
    }
}

// Custom Tab Bar matching Figma design
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let couplePhoto: UIImage?

    private let profileButtonSize: CGFloat = 52
    private let accentColor = Color(hex: Constants.Colors.accent)

    var body: some View {
        HStack(spacing: 0) {
            // Calendar Tab
            TabBarButton(
                icon: "",
                title: "Calendar",
                isSelected: selectedTab == 0,
                useCustomCalendarIcon: true
            ) {
                HapticManager.shared.buttonTap()
                selectedTab = 0
            }

            // Center profile button
            Button(action: {
                HapticManager.shared.buttonTap()
                selectedTab = 2
            }) {
                ZStack {
                    // Photo or placeholder
                    if let photo = couplePhoto {
                        Image(uiImage: photo)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: profileButtonSize, height: profileButtonSize)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(
                                        selectedTab == 2 ? accentColor : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                    } else {
                        Circle()
                            .fill(accentColor.opacity(0.15))
                            .frame(width: profileButtonSize, height: profileButtonSize)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(accentColor)
                            )
                            .overlay(
                                Circle()
                                    .stroke(
                                        selectedTab == 2 ? accentColor : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                    }
                }
                .frame(maxWidth: .infinity)
            }

            // To-Do Tab
            TabBarButton(
                icon: "list.bullet.clipboard",
                title: "To-Do",
                isSelected: selectedTab == 1
            ) {
                HapticManager.shared.buttonTap()
                selectedTab = 1
            }
        }
        .padding(.top, 1)
        .background(
            Color.white
                .shadow(color: .black.opacity(0.05), radius: 0, x: 0, y: -1)
        )
        .overlay(
            Rectangle()
                .fill(Color(hex: Constants.Colors.calendarBorder))
                .frame(height: 1),
            alignment: .top
        )
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    var useCustomCalendarIcon: Bool = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                if useCustomCalendarIcon {
                    FlipCalendarIcon()
                        .frame(width: 22, height: 22)
                        .frame(height: 24)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .frame(height: 24)
                }

                Text(title)
                    .font(.system(size: 10, weight: .regular))
                    .tracking(0.12)
            }
            .foregroundColor(
                isSelected ?
                Color(hex: Constants.Colors.tabActive) :
                Color(hex: Constants.Colors.tabInactive)
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
    }
}

// Custom flip calendar icon with grommets, curled corner, and heart
struct FlipCalendarIcon: View {
    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let strokeWidth: CGFloat = size * 0.09
            let cornerRadius: CGFloat = size * 0.14
            let grommetRadius: CGFloat = size * 0.08
            let grommetY: CGFloat = size * 0.12
            let curlSize: CGFloat = size * 0.18

            ZStack {
                // Main calendar body with curled corner
                Path { path in
                    let rect = CGRect(x: strokeWidth / 2, y: grommetY, width: size - strokeWidth, height: size - grommetY - strokeWidth / 2)

                    // Start at top-left corner
                    path.move(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY))

                    // Top edge
                    path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
                    path.addArc(
                        center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
                        radius: cornerRadius,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(0),
                        clockwise: false
                    )

                    // Right edge down to curl
                    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - curlSize))

                    // Curl corner
                    path.addLine(to: CGPoint(x: rect.maxX - curlSize, y: rect.maxY))

                    // Bottom edge
                    path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
                    path.addArc(
                        center: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius),
                        radius: cornerRadius,
                        startAngle: .degrees(90),
                        endAngle: .degrees(180),
                        clockwise: false
                    )

                    // Left edge
                    path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
                    path.addArc(
                        center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
                        radius: cornerRadius,
                        startAngle: .degrees(180),
                        endAngle: .degrees(270),
                        clockwise: false
                    )
                }
                .stroke(style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round, lineJoin: .round))

                // Curl detail line (the fold)
                Path { path in
                    let rect = CGRect(x: strokeWidth / 2, y: grommetY, width: size - strokeWidth, height: size - grommetY - strokeWidth / 2)
                    path.move(to: CGPoint(x: rect.maxX - curlSize, y: rect.maxY - curlSize))
                    path.addLine(to: CGPoint(x: rect.maxX - curlSize, y: rect.maxY))
                    path.move(to: CGPoint(x: rect.maxX - curlSize, y: rect.maxY - curlSize))
                    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - curlSize))
                }
                .stroke(style: StrokeStyle(lineWidth: strokeWidth * 0.7, lineCap: .round, lineJoin: .round))

                // Two filled grommets at top
                let grommetSpacing = size * 0.24
                let centerX = size / 2

                // Left grommet (filled)
                Circle()
                    .fill()
                    .frame(width: grommetRadius * 2, height: grommetRadius * 2)
                    .position(x: centerX - grommetSpacing, y: grommetY)

                // Right grommet (filled)
                Circle()
                    .fill()
                    .frame(width: grommetRadius * 2, height: grommetRadius * 2)
                    .position(x: centerX + grommetSpacing, y: grommetY)

                // Heart in center
                Image(systemName: "heart.fill")
                    .font(.system(size: size * 0.32))
                    .position(x: centerX, y: size * 0.58)
            }
        }
    }
}

#Preview {
    MainTabView()
}
