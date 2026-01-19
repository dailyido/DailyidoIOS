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
    @State private var selectedTab = 0
    @StateObject private var streakService = StreakService.shared
    @State private var showRemotePopup = false
    @State private var currentPopup: RemotePopup?
    @State private var couplePhoto: UIImage? = OnboardingViewModel.loadCouplePhoto()
    @State private var isTutorialShowing = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Content
                Group {
                    switch selectedTab {
                    case 0:
                        CalendarView(isTutorialShowing: $isTutorialShowing)
                    case 1:
                        ChecklistView()
                    case 2:
                        SettingsView()
                    default:
                        CalendarView(isTutorialShowing: $isTutorialShowing)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Custom Tab Bar
                ZStack {
                    CustomTabBar(selectedTab: $selectedTab, couplePhoto: couplePhoto)

                    // Dim overlay when tutorial is showing
                    if isTutorialShowing {
                        Color.black.opacity(0.4)
                            .allowsHitTesting(false)
                    }
                }
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
        }
        .task {
            await checkForRemotePopups()
        }
    }

    private func checkForRemotePopups() async {
        guard let user = AuthService.shared.currentUser,
              let weddingDate = user.weddingDate else { return }

        let daysOut = Date().daysUntil(weddingDate)
        let today = Date()

        do {
            let popups = try await SupabaseService.shared.fetchActivePopups()

            // Check for holiday popup (date-based)
            if let holidayPopup = popups.first(where: {
                $0.popupType == PopupType.holiday.rawValue &&
                $0.triggerDate != nil &&
                Calendar.current.isDate($0.triggerDate!, inSameDayAs: today)
            }) {
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
                await MainActor.run {
                    currentPopup = daysOutPopup
                    showRemotePopup = true
                }
            }
        } catch {
            print("Error fetching remote popups: \(error)")
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
