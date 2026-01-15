import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @StateObject private var streakService = StreakService.shared
    @State private var showShareOptions = false
    @State private var showInstagramAlert = false
    @State private var showFacebookAlert = false
    @State private var isSharing = false
    @State private var shareImage: UIImage?
    @State private var showTutorial = false
    @State private var showReminderSuccess = false
    @State private var showReminderError = false
    @State private var reminderErrorMessage = ""

    private let shouldShowTutorial = !UserDefaults.standard.bool(forKey: "hasSeenTutorial")
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

            if viewModel.isLoading {
                LoadingSpinner()
            } else {
                VStack(spacing: 0) {
                    // Action buttons in top right
                    HStack(spacing: 20) {
                        Spacer()

                        // Reminder button
                        Button(action: {
                            HapticManager.shared.buttonTap()
                            addToReminders()
                        }) {
                            Image(systemName: "bell")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: Constants.Colors.calendarTextPrimary))
                        }

                        // Share button
                        Button(action: {
                            HapticManager.shared.buttonTap()
                            showShareOptions = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: Constants.Colors.calendarTextPrimary))
                        }
                        .disabled(isSharing)
                    }
                    .padding(.trailing, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                    // Calendar card stack
                    GeometryReader { geometry in
                        VStack(spacing: 0) {
                            // Fixed header (stays in place)
                            CalendarHeaderView()
                                .zIndex(10)

                            // Tearable paper stack
                            ZStack(alignment: .top) {
                                // Preview page (shown behind when dragging)
                                Group {
                                    if viewModel.dragOffset > 20 {
                                        // Swiping right - show previous day's tip
                                        CalendarPaperContent(
                                            daysUntilWedding: viewModel.daysUntilWedding + 1,
                                            tip: viewModel.previewTip(for: viewModel.daysUntilWedding + 1),
                                            canTear: true,
                                            canGoBack: viewModel.daysUntilWedding + 1 < 365,
                                            statusMessage: ""
                                        )
                                    } else if viewModel.dragOffset < -20 {
                                        // Swiping left - show next day or "caught up" message
                                        if viewModel.canTear {
                                            CalendarPaperContent(
                                                daysUntilWedding: viewModel.daysUntilWedding - 1,
                                                tip: viewModel.previewTip(for: viewModel.daysUntilWedding - 1),
                                                canTear: viewModel.daysUntilWedding - 1 > viewModel.actualDaysUntilWedding,
                                                canGoBack: true,
                                                statusMessage: ""
                                            )
                                        } else {
                                            // Show "caught up" preview
                                            CalendarCaughtUpPreview()
                                        }
                                    }
                                }

                                // Main tearable paper page
                                CalendarPaperContent(
                                    daysUntilWedding: viewModel.daysUntilWedding,
                                    tip: viewModel.currentTip,
                                    canTear: viewModel.canTear,
                                    canGoBack: viewModel.canGoBack,
                                    statusMessage: viewModel.statusMessage
                                )
                                .modifier(TearAwayModifier(
                                    offset: viewModel.dragOffset,
                                    isDragging: viewModel.isDragging,
                                    hasSnapped: viewModel.hasSnapped,
                                    progress: viewModel.tearProgress,
                                    opacity: viewModel.tearOpacity
                                ))
                                .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.8), value: viewModel.dragOffset)
                                .animation(.easeOut(duration: 0.2), value: viewModel.tearOpacity)
                            }
                            .highPriorityGesture(
                                DragGesture(minimumDistance: 10)
                                    .onChanged { value in
                                        // Only handle horizontal drags (let vertical pass to ScrollView)
                                        let horizontalAmount = abs(value.translation.width)
                                        let verticalAmount = abs(value.translation.height)

                                        if horizontalAmount > verticalAmount {
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

            // Streak celebration popup
            if let milestone = streakService.showingMilestone {
                CelebrationPopup(milestone: milestone) {
                    streakService.dismissMilestone()
                }
            }

            // Tutorial overlay for first-time users
            if showTutorial {
                TutorialView(isPresented: $showTutorial)
                    .transition(.opacity)
            }
        }
        .task {
            await viewModel.loadData()

            // Delay tutorial to allow paywall to fully dismiss first
            if shouldShowTutorial {
                try? await Task.sleep(nanoseconds: 800_000_000) // 0.8 second delay
                withAnimation(.easeIn(duration: 0.3)) {
                    showTutorial = true
                }
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
            Text("This tip has been added to your Reminders app.")
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
    }

    // MARK: - Sharing Functions

    private func generateShareImage() -> UIImage? {
        let sharingService = InstagramSharingService.shared
        let shareableCard = ShareableCalendarCard(
            daysUntilWedding: viewModel.daysUntilWedding,
            tipTitle: viewModel.currentTip?.title ?? "Wedding Tip",
            tipText: viewModel.currentTip?.tipText ?? ""
        )
        let cardSize = CGSize(width: 1080, height: 1920)
        return sharingService.renderViewToImage(shareableCard, size: cardSize)
    }

    private func shareToInstagram() {
        guard !isSharing else { return }

        let sharingService = InstagramSharingService.shared

        guard sharingService.canShareToInstagram else {
            showInstagramAlert = true
            return
        }

        isSharing = true

        Task { @MainActor in
            if let image = generateShareImage() {
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

        let sharingService = InstagramSharingService.shared

        guard sharingService.canShareToFacebook else {
            showFacebookAlert = true
            return
        }

        isSharing = true

        Task { @MainActor in
            if let image = generateShareImage() {
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
        isSharing = true

        Task { @MainActor in
            if let image = generateShareImage() {
                shareImage = image
            }
            isSharing = false
        }
    }

    private func shareWithSystemSheet() {
        guard !isSharing else { return }
        isSharing = true

        Task { @MainActor in
            if let image = generateShareImage() {
                shareImage = image
            }
            isSharing = false
        }
    }

    // MARK: - Reminders

    private func addToReminders() {
        guard let tip = viewModel.currentTip else { return }

        Task {
            let title = "Wedding Tip: \(tip.title)"
            let notes = tip.tipText

            let result = await RemindersService.shared.createReminder(
                title: title,
                notes: notes
            )

            await MainActor.run {
                switch result {
                case .success:
                    HapticManager.shared.success()
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

    var body: some View {
        VStack(spacing: 0) {
            // Scrollable content area (vertical only, allows horizontal pass-through)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 24)

                    // Days countdown
                    Text("\(daysUntilWedding)")
                        .font(.system(size: 80, weight: .regular))
                        .foregroundColor(Color(hex: Constants.Colors.calendarTextPrimary))

                    Text("DAYS UNTIL YOUR WEDDING")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(3.1)
                        .foregroundColor(Color(hex: Constants.Colors.calendarTextTertiary))
                        .padding(.top, 8)

                    // Tip illustration from database (only if one exists)
                    if let tip = tip, tip.hasIllustration, let illustrationUrl = tip.fullIllustrationUrl {
                        CachedAsyncImage(url: URL(string: illustrationUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Color.clear
                        }
                        .frame(width: 96, height: 96)
                        .id(illustrationUrl)
                        .padding(.top, 24)
                    }

                    // Divider line
                    Color.clear
                        .frame(height: 1)
                        .padding(.top, 12)

                    // Today's Tip section
                    VStack(spacing: 12) {
                        Text("TODAY'S TIP")
                            .font(.system(size: 11, weight: .regular))
                            .tracking(2.26)
                            .foregroundColor(Color(hex: Constants.Colors.calendarTextSecondary))

                        if let tip = tip {
                            // Tip title from database
                            Text(tip.title)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color(hex: Constants.Colors.calendarTextPrimary))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)

                            // Tip text from database
                            Text(tip.tipText)
                                .font(.system(size: 16, weight: .regular))
                                .tracking(-0.44)
                                .lineSpacing(6)
                                .foregroundColor(Color(hex: Constants.Colors.calendarTextSecondary))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        } else {
                            Text("Loading tip...")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(Color(hex: Constants.Colors.calendarTextSecondary))
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 24)
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
                        if canTear {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 9, weight: .medium))
                                Text("tear")
                                    .font(.system(size: 10, weight: .regular))
                                    .tracking(0.5)
                            }
                        }

                        if canGoBack {
                            HStack(spacing: 4) {
                                Text("previous")
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
    var body: some View {
        VStack(spacing: 0) {
            // Header background with rings
            ZStack {
                // Header background
                Color(hex: Constants.Colors.calendarHeader)

                // Gold binding rings
                HStack {
                    GoldBindingRing()
                        .padding(.leading, 40)

                    Spacer()

                    GoldBindingRing()
                        .padding(.trailing, 40)
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
            HStack(spacing: 11) {
                ForEach(0..<20, id: \.self) { _ in
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 4, height: 4)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .padding(.leading, 11)
            .padding(.top, 4)
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

#Preview {
    CalendarView()
}
