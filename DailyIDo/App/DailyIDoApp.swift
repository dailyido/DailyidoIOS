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
        // TEMPORARY: Check for popups every time app becomes active (for testing)
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                Task {
                    await checkForRemotePopups()
                }
            }
        }
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
                print("DEBUG: Found matching holiday popup!")
                await MainActor.run {
                    currentPopup = holidayPopup
                    showRemotePopup = true
                }
                return
            }

            // Check for days_out popup (milestone like "30 days!")
            if let daysOutPopup = popups.first(where: {
                $0.popupType == PopupType.daysOut.rawValue &&
                $0.triggerDaysOut == daysOut
            }) {
                print("DEBUG: Found matching days_out popup!")
                await MainActor.run {
                    currentPopup = daysOutPopup
                    showRemotePopup = true
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
                icon: "calendar",
                title: "Calendar",
                isSelected: selectedTab == 0
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

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .frame(height: 24)

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

#Preview {
    MainTabView()
}
