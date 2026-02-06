import SwiftUI

struct CalendarView: View {
    @Binding var isTutorialShowing: Bool

    @StateObject private var viewModel = CalendarViewModel()
    @StateObject private var streakService = StreakService.shared
    @StateObject private var subscriptionService = SubscriptionService.shared
    @Environment(\.scenePhase) private var scenePhase
    @State private var showShareOptions = false
    @State private var showInstagramAlert = false
    @State private var showFacebookAlert = false
    @State private var isSharing = false
    @State private var shareImage: UIImage?
    @State private var showReminderOptions = false
    @State private var showCustomTimePicker = false
    @State private var customReminderDate = Date()
    @State private var showReminderSuccess = false
    @State private var showReminderError = false
    @State private var reminderErrorMessage = ""
    @State private var reminderSuccessMessage = ""
    @State private var showSettings = false
    @State private var showHeartAnimation = false
    @StateObject private var favoritesService = FavoritesService.shared

    private let primaryColor = Color(hex: Constants.Colors.buttonPrimary)

    var body: some View {
        ZStack {
            // Gradient background matching Figma
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 253/255, green: 242/255, blue: 248/255),
                    Color(red: 255/255, green: 241/255, blue: 242/255),
                    Color(red: 255/255, green: 251/255, blue: 235/255)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            if viewModel.isLoading || isTutorialShowing {
                // Show nothing behind the tutorial - just the gradient background
                if !isTutorialShowing {
                    LoadingSpinner()
                }
            } else {
                VStack(spacing: 0) {
                    // Action buttons
                    HStack(alignment: .bottom, spacing: 4) {
                        // Pro crown badge for free users (disappears after subscribing)
                        if !subscriptionService.isSubscribed {
                            Button(action: {
                                HapticManager.shared.buttonTap()
                                Task {
                                    await subscriptionService.showProBadgePaywall()
                                }
                            }) {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(hex: Constants.Colors.buttonPrimary))
                            }
                            .frame(width: 44, height: 44, alignment: .bottom)
                            .offset(x: 8, y: -8)
                        }

                        Spacer()

                        // Reminder button
                        Button(action: {
                            HapticManager.shared.buttonTap()
                            showReminderOptions = true
                        }) {
                            Image(systemName: "bell")
                                .font(.system(size: 22))
                                .foregroundColor(Color(hex: Constants.Colors.calendarTextPrimary))
                        }
                        .frame(width: 44, height: 44, alignment: .bottom)

                        // Share button
                        Button(action: {
                            HapticManager.shared.buttonTap()
                            showShareOptions = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 22))
                                .foregroundColor(Color(hex: Constants.Colors.calendarTextPrimary))
                        }
                        .frame(width: 44, height: 44, alignment: .bottom)
                        .disabled(isSharing)
                    }
                    .padding(.leading, 12)
                    .padding(.trailing, 20)
                    .offset(y: -8)

                    // Calendar card stack
                    GeometryReader { geometry in
                        VStack(spacing: 0) {
                            // Fixed header (stays in place)
                            CalendarHeaderView(onAddDateTapped: {
                                showSettings = true
                            })
                                .zIndex(10)

                            // Tearable paper stack
                            ZStack(alignment: .top) {
                                // Preview page (shown behind when dragging or during tear animation)
                                Group {
                                    if viewModel.dragOffset > 30 || (viewModel.isTearing && viewModel.tearDirection == .right) {
                                        // Swiping right - show previous day's tip (going back in time)
                                        CalendarPaperContent(
                                            daysUntilWedding: viewModel.daysUntilWedding + 1,
                                            tip: viewModel.cachedTip(for: viewModel.daysUntilWedding + 1),
                                            canTear: true,
                                            canGoBack: viewModel.daysUntilWedding + 1 < 730,
                                            statusMessage: ""
                                        )
                                    } else if viewModel.dragOffset < -30 || (viewModel.isTearing && viewModel.tearDirection == .left) {
                                        // Swiping left - show next day or "caught up" message
                                        if viewModel.canTear {
                                            CalendarPaperContent(
                                                daysUntilWedding: viewModel.daysUntilWedding - 1,
                                                tip: viewModel.cachedTip(for: viewModel.daysUntilWedding - 1),
                                                canTear: viewModel.daysUntilWedding - 1 > viewModel.actualDaysUntilWedding,
                                                canGoBack: true,
                                                statusMessage: ""
                                            )
                                        } else {
                                            CalendarCaughtUpPreview()
                                        }
                                    }
                                }
                                .zIndex(0)

                                // Main tearable paper page
                                CalendarPaperContent(
                                    daysUntilWedding: viewModel.daysUntilWedding,
                                    tip: viewModel.currentTip,
                                    canTear: viewModel.canTear,
                                    canGoBack: viewModel.canGoBack,
                                    statusMessage: viewModel.statusMessage,
                                    isFavorited: viewModel.currentTip.map { favoritesService.isFavorite($0.id) } ?? false,
                                    onDoubleTap: {
                                        print("💖 [Calendar] Double tap detected!")
                                        guard let tip = viewModel.currentTip else {
                                            print("💖 [Calendar] No current tip!")
                                            return
                                        }
                                        print("💖 [Calendar] Toggling favorite for tip: \(tip.id) - \(tip.title)")
                                        Task {
                                            let isFavorited = await favoritesService.toggleFavorite(tipId: tip.id)
                                            print("💖 [Calendar] Toggle result - isFavorited: \(isFavorited)")
                                            if isFavorited {
                                                showHeartAnimation = true
                                            }
                                        }
                                    }
                                )
                                .modifier(TearAwayModifier(
                                    offset: viewModel.dragOffset,
                                    isDragging: viewModel.isDragging,
                                    hasSnapped: viewModel.hasSnapped,
                                    progress: viewModel.tearProgress,
                                    opacity: viewModel.tearOpacity
                                ))
                                .zIndex(1)
                                .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.8), value: viewModel.dragOffset)
                                .animation(.easeOut(duration: 0.2), value: viewModel.tearOpacity)
                            }
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 20)
                                    .onChanged { value in
                                        // Only handle horizontal drags (let vertical pass to ScrollView)
                                        let horizontalAmount = abs(value.translation.width)
                                        let verticalAmount = abs(value.translation.height)

                                        // Require significantly more horizontal than vertical movement
                                        if horizontalAmount > verticalAmount * 1.5 {
                                            // Reset if previous animation is still running
                                            if viewModel.isTearing {
                                                viewModel.forceResetForNewGesture()
                                            }

                                            if !viewModel.isDragging {
                                                viewModel.startDrag()
                                            }
                                            viewModel.updateDrag(offset: value.translation.width)
                                        }
                                    }
                                    .onEnded { value in
                                        // Always try to handle the drag end if we were dragging
                                        if viewModel.isDragging {
                                            viewModel.handleDragEnd(
                                                translation: value.translation.width,
                                                velocity: value.predictedEndLocation.x - value.location.x,
                                                screenWidth: geometry.size.width
                                            )
                                        } else {
                                            // Fallback: if isDragging got stuck false, still try to complete
                                            viewModel.forceResetForNewGesture()
                                        }
                                    }
                            )
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20) // Small space above tab bar
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(color: .black.opacity(0.25), radius: 25, x: 0, y: 25)
                    }
                }
            }

            // "Go to Today" floating button (shows when 6+ days back)
            if viewModel.shouldShowGoToToday {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        GoToTodayButton {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                viewModel.jumpToToday()
                            }
                        }
                        .padding(.trailing, 32)
                        .padding(.bottom, 24)
                    }
                }
                .transition(.scale.combined(with: .opacity))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.shouldShowGoToToday)
            }

            // Streak celebration popup
            if let milestone = streakService.showingMilestone {
                CelebrationPopup(milestone: milestone) {
                    streakService.dismissMilestone()
                }
            }

            // Heart favorite animation
            HeartFavoriteAnimation(isShowing: $showHeartAnimation)
        }
        .task {
            await viewModel.loadData()
            await favoritesService.loadFavorites()
        }
        .onAppear {
            // Refresh when returning from settings (e.g., wedding date changed)
            viewModel.refreshIfNeeded()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                viewModel.refreshIfNeeded()
            }
        }
        .sheet(isPresented: $showShareOptions) {
            ShareOptionsSheet(
                onInstagram: {
                    showShareOptions = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        shareToInstagram()
                    }
                },
                onFacebook: {
                    showShareOptions = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        shareToFacebook()
                    }
                },
                onMessages: {
                    showShareOptions = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        shareToMessages()
                    }
                },
                onMore: {
                    showShareOptions = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        shareWithSystemSheet()
                    }
                },
                onCancel: {
                    showShareOptions = false
                }
            )
            .presentationDetents([.height(340)])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showReminderOptions) {
            ReminderOptionsSheet(
                onTomorrowMorning: {
                    showReminderOptions = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        addToReminders(at: tomorrowAt(hour: 9, minute: 0))
                    }
                },
                onTomorrowEvening: {
                    showReminderOptions = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        addToReminders(at: tomorrowAt(hour: 19, minute: 0))
                    }
                },
                onCustomTime: {
                    showReminderOptions = false
                    customReminderDate = tomorrowAt(hour: 9, minute: 0)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showCustomTimePicker = true
                    }
                },
                onCancel: {
                    showReminderOptions = false
                }
            )
            .presentationDetents([.height(320)])
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showCustomTimePicker) {
            CustomTimePickerSheet(
                selectedDate: $customReminderDate,
                onConfirm: {
                    showCustomTimePicker = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        addToReminders(at: customReminderDate)
                    }
                },
                onCancel: {
                    showCustomTimePicker = false
                }
            )
            .presentationDetents([.height(520)])
            .presentationDragIndicator(.hidden)
        }
        .alert("Instagram Not Installed", isPresented: $showInstagramAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please install Instagram to share your wedding countdown to Stories.")
        }
        .alert("Facebook Not Installed", isPresented: $showFacebookAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please install Facebook to share your wedding countdown to Stories.")
        }
        .alert("Reminder Added", isPresented: $showReminderSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(reminderSuccessMessage)
        }
        .alert("Couldn't Add Reminder", isPresented: $showReminderError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(reminderErrorMessage)
        }
        .sheet(isPresented: Binding(
            get: { shareImage != nil },
            set: { if !$0 { shareImage = nil } }
        )) {
            if let image = shareImage {
                ShareSheet(items: [image])
            }
        }
        .sheet(isPresented: $showSettings, onDismiss: {
            // Refresh calendar data when settings is dismissed (in case wedding date changed)
            viewModel.isLoading = true
            Task {
                await viewModel.loadData()
            }
        }) {
            SettingsView(onDone: {
                showSettings = false
            })
        }
    }

    // MARK: - Sharing Functions

    private func generateShareImage(with illustrationImage: UIImage? = nil) -> UIImage? {
        let sharingService = InstagramSharingService.shared
        let shareableCard = ShareableCalendarCard(
            daysUntilWedding: viewModel.daysUntilWedding,
            tipTitle: viewModel.currentTip?.title ?? "Wedding Tip",
            tipText: viewModel.currentTip?.tipText ?? "",
            illustrationImage: illustrationImage
        )
        let cardSize = CGSize(width: 1080, height: 1920)
        return sharingService.renderViewToImage(shareableCard, size: cardSize)
    }

    private func loadIllustrationImage() async -> UIImage? {
        guard let tip = viewModel.currentTip,
              let urlString = RandomIllustrationService.shared.getIllustrationUrl(for: tip),
              let url = URL(string: urlString) else {
            return nil
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("Failed to load illustration for sharing: \(error)")
            return nil
        }
    }

    private func shareToInstagram() {
        guard !isSharing else { return }

        // Track share analytics
        if let tip = viewModel.currentTip {
            AnalyticsService.shared.logShareTapped(tipId: tip.id, platform: "instagram")
        }

        let sharingService = InstagramSharingService.shared

        guard sharingService.canShareToInstagram else {
            showInstagramAlert = true
            return
        }

        isSharing = true

        Task { @MainActor in
            // Load illustration first
            let illustrationImage = await loadIllustrationImage()
            if let image = generateShareImage(with: illustrationImage) {
                sharingService.shareToInstagramStories(image: image) { success in
                    DispatchQueue.main.async {
                        isSharing = false
                        if success {
                            HapticManager.shared.success()
                        }
                    }
                }
            } else {
                isSharing = false
            }
        }
    }

    private func shareToFacebook() {
        guard !isSharing else { return }

        // Track share analytics
        if let tip = viewModel.currentTip {
            AnalyticsService.shared.logShareTapped(tipId: tip.id, platform: "facebook")
        }

        let sharingService = InstagramSharingService.shared

        guard sharingService.canShareToFacebook else {
            showFacebookAlert = true
            return
        }

        isSharing = true

        Task { @MainActor in
            // Load illustration first
            let illustrationImage = await loadIllustrationImage()
            if let image = generateShareImage(with: illustrationImage) {
                sharingService.shareToFacebookStories(image: image) { success in
                    DispatchQueue.main.async {
                        isSharing = false
                        if success {
                            HapticManager.shared.success()
                        }
                    }
                }
            } else {
                isSharing = false
            }
        }
    }

    private func shareToMessages() {
        guard !isSharing else { return }

        // Track share analytics
        if let tip = viewModel.currentTip {
            AnalyticsService.shared.logShareTapped(tipId: tip.id, platform: "messages")
        }

        isSharing = true

        Task { @MainActor in
            // Load illustration first
            let illustrationImage = await loadIllustrationImage()
            if let image = generateShareImage(with: illustrationImage) {
                shareImage = image
            }
            isSharing = false
        }
    }

    private func shareWithSystemSheet() {
        guard !isSharing else { return }

        // Track share analytics
        if let tip = viewModel.currentTip {
            AnalyticsService.shared.logShareTapped(tipId: tip.id, platform: "system_sheet")
        }

        isSharing = true

        Task { @MainActor in
            // Load illustration first
            let illustrationImage = await loadIllustrationImage()
            if let image = generateShareImage(with: illustrationImage) {
                shareImage = image
            }
            isSharing = false
        }
    }

    // MARK: - Reminders

    private func tomorrowAt(hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        var components = calendar.dateComponents([.year, .month, .day], from: tomorrow)
        components.hour = hour
        components.minute = minute
        return calendar.date(from: components) ?? tomorrow
    }

    private func formatReminderTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE 'at' h:mm a"
        return formatter.string(from: date)
    }

    private func addToReminders(at date: Date) {
        guard let tip = viewModel.currentTip else { return }

        // Track reminder analytics
        AnalyticsService.shared.logReminderTapped(tipId: tip.id)

        Task {
            let title = "Wedding Tip: \(tip.title)"
            let notes = tip.tipText

            let result = await RemindersService.shared.createReminder(
                title: title,
                notes: notes,
                dueDate: date
            )

            await MainActor.run {
                switch result {
                case .success:
                    HapticManager.shared.success()
                    reminderSuccessMessage = "Reminder set for \(formatReminderTime(date))"
                    showReminderSuccess = true
                case .failure(let error):
                    reminderErrorMessage = error.localizedDescription
                    showReminderError = true
                }
            }
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// Background paper page for stack effect (no header)
struct CalendarPaperBackground: View {
    let opacity: Double

    var body: some View {
        Rectangle()
            .fill(Color(hex: Constants.Colors.calendarCard))
            .overlay(
                Rectangle()
                    .stroke(Color(hex: Constants.Colors.calendarBorder), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
            .opacity(opacity)
    }
}

// "Caught up" preview shown when user tries to swipe forward but can't
struct CalendarCaughtUpPreview: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
                .frame(height: 24)

            Image(systemName: "clock.fill")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: Constants.Colors.accent))

            Text("That's all for now!")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(Color(hex: Constants.Colors.calendarTextPrimary))

            Text("Check in tomorrow\nfor your next tip")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color(hex: Constants.Colors.calendarTextSecondary))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color(hex: Constants.Colors.calendarCard))
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 16,
                bottomTrailingRadius: 16,
                topTrailingRadius: 0
            )
        )
    }
}

// Tearable paper content (the white page that tears away)
struct CalendarPaperContent: View {
    let daysUntilWedding: Int
    let tip: Tip?
    let canTear: Bool
    let canGoBack: Bool
    let statusMessage: String
    var isFavorited: Bool = false
    var onDoubleTap: (() -> Void)? = nil

    private var hasWeddingDate: Bool {
        AuthService.shared.currentUser?.weddingDate != nil
    }

    /// Process tip text to replace placeholders like XXXX with calculated values
    private func processedTipText(_ text: String) -> String {
        var result = text

        // Replace XXXX with sunset time for the user's wedding date/location
        if result.contains("XXXX"),
           let user = AuthService.shared.currentUser,
           let weddingDate = user.weddingDate,
           let latitude = user.weddingLatitude,
           let longitude = user.weddingLongitude,
           let sunsetTime = SunsetService.shared.formattedSunsetTime(for: weddingDate, latitude: latitude, longitude: longitude) {
            result = result.replacingOccurrences(of: "XXXX", with: sunsetTime)
        }

        return result
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                // Scrollable content area (vertical only, allows horizontal pass-through)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 24)

                        if hasWeddingDate {
                        // Days countdown
                        Text("\(daysUntilWedding)")
                            .font(.system(size: 80, weight: .regular))
                            .foregroundColor(Color(hex: "#254059"))

                        Text("DAYS UNTIL YOUR WEDDING")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(3.1)
                            .foregroundColor(Color(hex: Constants.Colors.calendarTextTertiary))
                            .padding(.top, 8)
                    } else {
                        // No wedding date set
                        Image(systemName: "heart.fill")
                            .font(.system(size: 50))
                            .foregroundColor(Color(hex: Constants.Colors.accent))

                        Text("WEDDING PLANNING TIP")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(3.1)
                            .foregroundColor(Color(hex: Constants.Colors.calendarTextTertiary))
                            .padding(.top, 12)
                    }

                    // Tip illustration (own or random fallback)
                    if let tip = tip {
                        TipIllustrationView(tip: tip, size: 115)
                            .padding(.top, 16)
                    }

                    // Today's Tip section
                    VStack(spacing: 10) {
                        Text("TODAY'S TIP")
                            .font(.system(size: 11, weight: .regular))
                            .tracking(2.26)
                            .foregroundColor(Color(hex: Constants.Colors.calendarTextSecondary))

                        if let tip = tip {
                            // Tip title from database
                            Text(tip.title.replacingOccurrences(of: "\\n", with: "\n"))
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color(hex: Constants.Colors.calendarTextPrimary))
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 24)

                            // Tip text from database (supports \n for line breaks and XXXX placeholders)
                            Text(processedTipText(tip.tipText).replacingOccurrences(of: "\\n", with: "\n"))
                                .font(.system(size: 16, weight: .regular))
                                .tracking(-0.44)
                                .lineSpacing(6)
                                .foregroundColor(Color(hex: Constants.Colors.calendarTextSecondary))
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 24)
                        } else {
                            Text("Loading tip...")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(Color(hex: Constants.Colors.calendarTextSecondary))
                        }
                    }
                    .padding(.top, 6)
                    .padding(.bottom, 20)
                }
            }

            // Affiliate link button (if tip has one)
            if let tip = tip, let affiliateUrl = tip.affiliateUrl, let url = URL(string: affiliateUrl) {
                Link(destination: url) {
                    Text(tip.affiliateButtonText ?? "Learn More")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: Constants.Colors.buttonPrimary))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(Color(hex: Constants.Colors.accent))
                        )
                        .shadow(color: Color(hex: Constants.Colors.accent).opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.top, 8)
                .padding(.bottom, 16)
            }

            // Swipe hints / status message (fixed at bottom)
            VStack(spacing: 8) {
                if !statusMessage.isEmpty && !canTear {
                    // Show status message (first day or caught up)
                    Text(statusMessage)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: Constants.Colors.calendarTextSecondary))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                // Compact swipe hints
                if canTear || canGoBack {
                    HStack(spacing: 16) {
                        if canGoBack {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 9, weight: .medium))
                                Text("Previous")
                                    .font(.system(size: 10, weight: .regular))
                                    .tracking(0.5)
                            }
                        }

                        if canTear {
                            HStack(spacing: 4) {
                                Text("Next")
                                    .font(.system(size: 10, weight: .regular))
                                    .tracking(0.5)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 9, weight: .medium))
                            }
                        }
                    }
                    .foregroundColor(Color(hex: Constants.Colors.calendarTextMuted))
                }
            }
            .padding(.bottom, 16)
            }

            // Favorited heart indicator in upper right corner
            if isFavorited {
                Image(systemName: "heart.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: Constants.Colors.accent))
                    .padding(12)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color(hex: Constants.Colors.calendarCard))
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 16,
                bottomTrailingRadius: 16,
                topTrailingRadius: 0
            )
        )
        .onTapGesture(count: 2) {
            if tip != nil {
                onDoubleTap?()
            }
        }
    }
}

// Page curl effect for bottom right corner
struct PageCurlCorner: View {
    private let size: CGFloat = 36

    var body: some View {
        Canvas { context, canvasSize in
            // Shadow underneath the fold
            let shadowPath = Path { path in
                path.move(to: CGPoint(x: size, y: 0))
                path.addLine(to: CGPoint(x: size, y: size))
                path.addLine(to: CGPoint(x: 0, y: size))
                path.closeSubpath()
            }
            context.drawLayer { ctx in
                ctx.addFilter(.shadow(color: .black.opacity(0.25), radius: 4, x: -2, y: -2))
                ctx.fill(shadowPath, with: .color(Color(white: 0.85)))
            }

            // The "underneath" part (darker to show depth)
            let underPath = Path { path in
                path.move(to: CGPoint(x: size, y: 0))
                path.addLine(to: CGPoint(x: size, y: size))
                path.addLine(to: CGPoint(x: 0, y: size))
                path.closeSubpath()
            }
            context.fill(underPath, with: .color(Color(white: 0.88)))

            // The folded triangle (the visible curl)
            let foldPath = Path { path in
                path.move(to: CGPoint(x: size, y: 0))
                path.addLine(to: CGPoint(x: 0, y: size))
                path.addLine(to: CGPoint(x: size * 0.5, y: size * 0.5))
                path.closeSubpath()
            }

            // Gradient for the fold
            let foldGradient = Gradient(colors: [
                Color(white: 0.97),
                Color(white: 0.91)
            ])
            context.fill(
                foldPath,
                with: .linearGradient(
                    foldGradient,
                    startPoint: CGPoint(x: size, y: 0),
                    endPoint: CGPoint(x: 0, y: size)
                )
            )

            // Subtle line on the fold edge
            let edgePath = Path { path in
                path.move(to: CGPoint(x: size, y: 0))
                path.addLine(to: CGPoint(x: 0, y: size))
            }
            context.stroke(edgePath, with: .color(Color(white: 0.82)), lineWidth: 0.5)
        }
        .frame(width: size, height: size)
        .padding(.trailing, 12)
        .padding(.bottom, 12)
    }
}

// Calendar header with binding rings
struct CalendarHeaderView: View {
    var userName: String? = AuthService.shared.currentUser?.name
    var partnerName: String? = AuthService.shared.currentUser?.partnerName
    var weddingDate: Date? = AuthService.shared.currentUser?.weddingDate
    var onAddDateTapped: (() -> Void)? = nil

    private var coupleNames: String? {
        guard let name = userName, !name.isEmpty,
              let partner = partnerName, !partner.isEmpty else {
            return nil
        }
        return "\(name) & \(partner)"
    }

    private var formattedWeddingDate: String? {
        guard let date = weddingDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header background with rings
            ZStack {
                // Header background
                Color(hex: Constants.Colors.calendarHeader)

                // Gold binding rings and couple names
                HStack {
                    GoldBindingRing()
                        .padding(.leading, 20)

                    Spacer()

                    // Couple names and wedding date in center
                    VStack(spacing: 2) {
                        if let names = coupleNames {
                            Text(names)
                                .font(.custom("Didot-Bold", size: 24))
                                .tracking(1)
                                .foregroundColor(.white.opacity(0.95))
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                        }
                        if let dateStr = formattedWeddingDate {
                            Text(dateStr)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                                .tracking(1)
                        } else {
                            // No wedding date set - show tappable prompt
                            Button(action: {
                                HapticManager.shared.buttonTap()
                                onAddDateTapped?()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 12))
                                    Text("Add Your Wedding Date")
                                        .font(.system(size: 13, weight: .medium))
                                }
                                .foregroundColor(Color(hex: Constants.Colors.accent))
                            }
                        }
                    }
                    .padding(.top, 8)

                    Spacer()

                    GoldBindingRing()
                        .padding(.trailing, 20)
                }
            }
            .frame(height: 68)

            // Perforated edge
            PerforatedEdge()
                .frame(height: 12)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0),
                            Color.black.opacity(0.05)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 16,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 16
            )
        )
    }
}

// Gold binding ring with gradient and shadows
struct GoldBindingRing: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: Constants.Colors.goldLight),
                            Color(hex: Constants.Colors.goldMid),
                            Color(hex: Constants.Colors.goldDark)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 24, height: 24)
                .shadow(color: .black.opacity(0.4), radius: 5, x: 0, y: 3)

            // Inner highlight
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.6),
                            Color.clear
                        ]),
                        startPoint: .top,
                        endPoint: .center
                    )
                )
                .frame(width: 20, height: 20)
                .offset(y: -2)

            // Inner shadow
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.black.opacity(0.3)
                        ]),
                        startPoint: .center,
                        endPoint: .bottom
                    )
                )
                .frame(width: 20, height: 20)
                .offset(y: 2)
        }
        .padding(.top, 16)
    }
}

// Perforated edge (dots along tear line)
struct PerforatedEdge: View {
    var body: some View {
        GeometryReader { geometry in
            let dotSize: CGFloat = 4
            let spacing: CGFloat = 11
            let totalDotWidth = dotSize + spacing
            let numberOfDots = Int(geometry.size.width / totalDotWidth)

            HStack(spacing: spacing) {
                ForEach(0..<numberOfDots, id: \.self) { _ in
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: dotSize, height: dotSize)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
        }
        .background(Color(hex: Constants.Colors.calendarHeader))
    }
}

// Custom share options sheet with dark blue text
struct ShareOptionsSheet: View {
    let onInstagram: () -> Void
    let onFacebook: () -> Void
    let onMessages: () -> Void
    let onMore: () -> Void
    let onCancel: () -> Void

    private let primaryColor = Color(hex: Constants.Colors.buttonPrimary)
    private let secondaryText = Color(hex: Constants.Colors.secondaryText)

    var body: some View {
        VStack(spacing: 0) {
            // Title
            Text("Share Today's Tip")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(primaryColor)
                .padding(.top, 20)
                .padding(.bottom, 24)

            // Options
            VStack(spacing: 0) {
                ShareOptionButton(
                    icon: "camera.fill",
                    title: "Instagram Stories",
                    color: primaryColor,
                    action: onInstagram
                )

                Divider()
                    .padding(.horizontal, 20)

                ShareOptionButton(
                    icon: "f.square.fill",
                    title: "Facebook Stories",
                    color: primaryColor,
                    action: onFacebook
                )

                Divider()
                    .padding(.horizontal, 20)

                ShareOptionButton(
                    icon: "message.fill",
                    title: "Text Message",
                    color: primaryColor,
                    action: onMessages
                )

                Divider()
                    .padding(.horizontal, 20)

                ShareOptionButton(
                    icon: "ellipsis.circle.fill",
                    title: "More Options...",
                    color: primaryColor,
                    action: onMore
                )
            }

            Spacer()

            // Cancel button
            Button(action: onCancel) {
                Text("Cancel")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .padding(.bottom, 20)
        }
        .background(Color.white)
    }
}

struct ShareOptionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.buttonTap()
            action()
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 28)

                Text(title)
                    .font(.system(size: 17))
                    .foregroundColor(color)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(color.opacity(0.4))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
    }
}

// MARK: - Reminder Options Sheet

struct ReminderOptionsSheet: View {
    let onTomorrowMorning: () -> Void
    let onTomorrowEvening: () -> Void
    let onCustomTime: () -> Void
    let onCancel: () -> Void

    private let primaryColor = Color(hex: Constants.Colors.buttonPrimary)
    private let secondaryText = Color(hex: Constants.Colors.secondaryText)

    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 8)

            // Title
            Text("Set Reminder")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(primaryColor)
                .padding(.top, 16)
                .padding(.bottom, 20)

            // Options
            VStack(spacing: 0) {
                ReminderOptionButton(
                    icon: "sun.rise.fill",
                    title: "Tomorrow morning",
                    subtitle: "9:00 AM",
                    color: primaryColor,
                    action: onTomorrowMorning
                )

                Divider()
                    .padding(.horizontal, 20)

                ReminderOptionButton(
                    icon: "moon.fill",
                    title: "Tomorrow evening",
                    subtitle: "7:00 PM",
                    color: primaryColor,
                    action: onTomorrowEvening
                )

                Divider()
                    .padding(.horizontal, 20)

                ReminderOptionButton(
                    icon: "clock.fill",
                    title: "Custom time...",
                    subtitle: nil,
                    color: primaryColor,
                    action: onCustomTime
                )
            }

            Spacer()

            // Cancel button
            Button(action: onCancel) {
                Text("Cancel")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
        .background(Color.white)
    }
}

struct ReminderOptionButton: View {
    let icon: String
    let title: String
    let subtitle: String?
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.buttonTap()
            action()
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 17))
                        .foregroundColor(color)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 13))
                            .foregroundColor(color.opacity(0.6))
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(color.opacity(0.4))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
    }
}

// MARK: - Custom Time Picker Sheet

struct CustomTimePickerSheet: View {
    @Binding var selectedDate: Date
    let onConfirm: () -> Void
    let onCancel: () -> Void

    private let primaryColor = Color(hex: Constants.Colors.buttonPrimary)
    private let accentColor = Color(hex: Constants.Colors.accent)
    private let secondaryText = Color(hex: Constants.Colors.secondaryText)

    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 8)

            // Date Picker - graphical for date selection
            DatePicker(
                "Reminder Date",
                selection: $selectedDate,
                in: Date()...,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
            .tint(accentColor)
            .padding(.horizontal, 16)
            .padding(.top, 8)

            // Time row - always visible
            HStack {
                Text("Time")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(primaryColor)

                Spacer()

                DatePicker(
                    "",
                    selection: $selectedDate,
                    displayedComponents: [.hourAndMinute]
                )
                .labelsHidden()
                .tint(accentColor)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.white)

            // Buttons - fixed at bottom
            HStack(spacing: 12) {
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }

                Button(action: onConfirm) {
                    Text("Set Reminder")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(accentColor)
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .background(Color.white)
    }
}

// Floating "Go to Today" button
struct GoToTodayButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.success()
            action()
        }) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.right.to.line")
                    .font(.system(size: 14, weight: .semibold))
                Text("Go to Today")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color(hex: Constants.Colors.buttonPrimary))
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            )
        }
    }
}

#Preview {
    CalendarView(isTutorialShowing: .constant(false))
}
