import SwiftUI

struct FavoriteDetailView: View {
    let tip: Tip
    let onUnfavorite: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showShareOptions = false
    @State private var showReminderOptions = false
    @State private var showCustomTimePicker = false
    @State private var customReminderDate = Date()
    @State private var showReminderSuccess = false
    @State private var showReminderError = false
    @State private var reminderErrorMessage = ""
    @State private var reminderSuccessMessage = ""
    @State private var isSharing = false
    @State private var shareImage: UIImage?
    @State private var showInstagramAlert = false
    @State private var showFacebookAlert = false

    private var favoritedDateString: String {
        guard let date = FavoritesService.shared.favoritedDates[tip.id] else {
            return "Saved tip"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return "Saved on \(formatter.string(from: date))"
    }

    var body: some View {
        ZStack {
            Color(hex: Constants.Colors.background)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Close button at top
                HStack {
                    Spacer()
                    Button(action: {
                        HapticManager.shared.buttonTap()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Color(hex: Constants.Colors.cardBackground)))
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 16)
                }

                // Card content matching calendar style
                VStack(spacing: 0) {
                    // Saved date header
                    Text(favoritedDateString)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                        .padding(.top, 24)
                        .padding(.bottom, 20)

                    Divider()
                        .padding(.horizontal, 24)

                    ScrollView(showsIndicators: true) {
                        VStack(spacing: 20) {
                            // Illustration
                            if let urlString = RandomIllustrationService.shared.getIllustrationUrl(for: tip) {
                                CachedAsyncImage(url: URL(string: urlString)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxHeight: 180)
                                } placeholder: {
                                    ProgressView()
                                        .frame(height: 150)
                                }
                                .padding(.top, 20)
                            }

                            // Tip title
                            Text(tip.title.replacingOccurrences(of: "\\n", with: "\n"))
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Color(hex: Constants.Colors.primaryText))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                                .padding(.top, RandomIllustrationService.shared.getIllustrationUrl(for: tip) != nil ? 0 : 20)

                            // Tip text
                            Text(tip.tipText.replacingOccurrences(of: "\\n", with: "\n"))
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .padding(.horizontal, 24)
                                .fixedSize(horizontal: false, vertical: true)

                            // Affiliate button
                            if let affiliateUrl = tip.affiliateUrl, !affiliateUrl.isEmpty {
                                Button(action: {
                                    URLHelper.openSmartURL(affiliateUrl)
                                }) {
                                    HStack {
                                        Text(tip.affiliateButtonText ?? "Shop Now")
                                            .font(.system(size: 15, weight: .medium))
                                        Image(systemName: "arrow.up.right")
                                            .font(.system(size: 13))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(hex: "#847996"))
                                    )
                                }
                                .padding(.top, 8)
                            }
                        }
                        .padding(.bottom, 20)
                    }

                    // Action buttons row
                    HStack(spacing: 12) {
                        // Share button
                        Button(action: {
                            HapticManager.shared.buttonTap()
                            showShareOptions = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 16))
                                Text("Share")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(Color(hex: Constants.Colors.primaryText))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.1))
                            )
                        }

                        // Reminder button
                        Button(action: {
                            HapticManager.shared.buttonTap()
                            showReminderOptions = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "bell")
                                    .font(.system(size: 16))
                                Text("Remind")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(Color(hex: Constants.Colors.primaryText))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.1))
                            )
                        }

                        // Unfavorite button
                        Button(action: {
                            HapticManager.shared.buttonTap()
                            onUnfavorite()
                            dismiss()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: Constants.Colors.accent))
                                Text("Saved")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(Color(hex: Constants.Colors.primaryText))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: Constants.Colors.accent).opacity(0.3), lineWidth: 1)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(hex: Constants.Colors.accent).opacity(0.05))
                                    )
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(hex: Constants.Colors.cardBackground))
                        .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 8)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            AnalyticsService.shared.logFavoriteDetailViewed(tipId: tip.id)
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
        .alert("Instagram Not Installed", isPresented: $showInstagramAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please install Instagram to share.")
        }
        .alert("Facebook Not Installed", isPresented: $showFacebookAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please install Facebook to share.")
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

    // MARK: - Sharing

    private func generateShareImage(with illustrationImage: UIImage? = nil) -> UIImage? {
        let sharingService = InstagramSharingService.shared
        let shareableCard = ShareableCalendarCard(
            daysUntilWedding: {
                guard let weddingDate = AuthService.shared.currentUser?.weddingDate else { return 0 }
                return Date().daysUntil(weddingDate)
            }(),
            tipTitle: tip.title,
            tipText: tip.tipText,
            illustrationImage: illustrationImage
        )
        let cardSize = CGSize(width: 1080, height: 1920)
        return sharingService.renderViewToImage(shareableCard, size: cardSize)
    }

    private func loadIllustrationImage() async -> UIImage? {
        guard let urlString = RandomIllustrationService.shared.getIllustrationUrl(for: tip),
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

        AnalyticsService.shared.logShareTapped(tipId: tip.id, platform: "instagram")

        let sharingService = InstagramSharingService.shared

        guard sharingService.canShareToInstagram else {
            showInstagramAlert = true
            return
        }

        isSharing = true

        Task { @MainActor in
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

        AnalyticsService.shared.logShareTapped(tipId: tip.id, platform: "facebook")

        let sharingService = InstagramSharingService.shared

        guard sharingService.canShareToFacebook else {
            showFacebookAlert = true
            return
        }

        isSharing = true

        Task { @MainActor in
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

        AnalyticsService.shared.logShareTapped(tipId: tip.id, platform: "messages")

        isSharing = true

        Task { @MainActor in
            let illustrationImage = await loadIllustrationImage()
            if let image = generateShareImage(with: illustrationImage) {
                shareImage = image
            }
            isSharing = false
        }
    }

    private func shareWithSystemSheet() {
        guard !isSharing else { return }

        AnalyticsService.shared.logShareTapped(tipId: tip.id, platform: "system_sheet")

        isSharing = true

        Task { @MainActor in
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

#Preview {
    FavoriteDetailView(
        tip: Tip(
            id: UUID(),
            title: "Start Your Guest List",
            tipText: "Begin compiling your guest list early. This will help you determine your venue size and budget. Start with immediate family and close friends, then expand from there.",
            hasIllustration: false,
            illustrationUrl: nil,
            category: "Planning",
            monthCategory: "12+ months",
            specificDay: nil,
            priority: 1,
            onChecklist: true,
            affiliateUrl: nil,
            affiliateButtonText: nil,
            weddingType: nil,
            isActive: true,
            funTip: false,
            createdAt: Date()
        ),
        onUnfavorite: {}
    )
}
