import SwiftUI
import PhotosUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showMeetThePlanners = false
    @State private var couplePhoto: UIImage? = OnboardingViewModel.loadCouplePhoto()
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isDatePickerExpanded = false
    var onDone: (() -> Void)?

    private let accentColor = Color(hex: Constants.Colors.accent)

    private var formattedWeddingDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: viewModel.weddingDate)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: Constants.Colors.background)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Couple Photo Section
                        SettingsSection(title: "Couple Photo") {
                            HStack(spacing: 20) {
                                // Photo display
                                ZStack {
                                    if let photo = couplePhoto {
                                        Image(uiImage: photo)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 80, height: 80)
                                            .clipShape(Circle())
                                    } else {
                                        Circle()
                                            .fill(accentColor.opacity(0.15))
                                            .frame(width: 80, height: 80)
                                            .overlay(
                                                Image(systemName: "person.2.fill")
                                                    .font(.system(size: 28))
                                                    .foregroundColor(accentColor)
                                            )
                                    }
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    Text(couplePhoto == nil ? "Add a photo" : "Change photo")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color(hex: Constants.Colors.primaryText))

                                    Text("This photo appears in your tab bar")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color(hex: Constants.Colors.secondaryText))

                                    PhotosPicker(
                                        selection: $selectedPhotoItem,
                                        matching: .images
                                    ) {
                                        Text(couplePhoto == nil ? "Choose Photo" : "Change")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(accentColor)
                                    }
                                    .onChange(of: selectedPhotoItem) { newItem in
                                        Task {
                                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                                               let image = UIImage(data: data) {
                                                couplePhoto = image
                                                saveCouplePhoto(image)
                                            }
                                        }
                                    }
                                }

                                Spacer()
                            }
                        }

                        // Wedding Details Section
                        SettingsSection(title: "Wedding Details") {
                            VStack(spacing: 16) {
                                // Wedding Date
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Wedding Date")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(hex: Constants.Colors.secondaryText))

                                    // Tappable date display
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            isDatePickerExpanded.toggle()
                                        }
                                    }) {
                                        HStack {
                                            Text(formattedWeddingDate)
                                                .font(.system(size: 16))
                                                .foregroundColor(Color(hex: Constants.Colors.primaryText))

                                            Spacer()

                                            Image(systemName: isDatePickerExpanded ? "chevron.up" : "chevron.down")
                                                .font(.system(size: 14))
                                                .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                                        }
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color(hex: Constants.Colors.background))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color(hex: Constants.Colors.calendarBorder), lineWidth: 1)
                                        )
                                    }

                                    // Expandable calendar picker
                                    if isDatePickerExpanded {
                                        DatePicker(
                                            "",
                                            selection: $viewModel.weddingDate,
                                            displayedComponents: .date
                                        )
                                        .datePickerStyle(.graphical)
                                        .tint(accentColor)
                                        .labelsHidden()
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                    }
                                }

                                // Wedding Location
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Wedding Location")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(hex: Constants.Colors.secondaryText))

                                    PlacesAutocompleteField(
                                        placeholder: "Search for a city...",
                                        selectedPlace: $viewModel.weddingTown,
                                        latitude: $viewModel.weddingLatitude,
                                        longitude: $viewModel.weddingLongitude
                                    )
                                }

                                // Tented Wedding Toggle
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Tented Wedding")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(Color(hex: Constants.Colors.primaryText))

                                        Text("Get tips specific to tented weddings")
                                            .font(.system(size: 13))
                                            .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                                    }

                                    Spacer()

                                    Toggle("", isOn: $viewModel.isTentedWedding)
                                        .tint(Color(hex: Constants.Colors.accent))
                                        .labelsHidden()
                                }
                                .padding(.vertical, 8)
                            }
                        }

                        // Profile Section
                        SettingsSection(title: "Your Details") {
                            VStack(spacing: 16) {
                                LabeledInputField(
                                    label: "Your Name",
                                    placeholder: "Enter your name",
                                    text: $viewModel.name
                                )

                                LabeledInputField(
                                    label: "Partner's Name",
                                    placeholder: "Enter partner's name",
                                    text: $viewModel.partnerName
                                )

                                LabeledInputField(
                                    label: "Email",
                                    placeholder: "email@example.com",
                                    text: $viewModel.email,
                                    keyboardType: .emailAddress
                                )
                            }
                        }

                        // Save Button
                        PrimaryButton(
                            title: viewModel.isSaving ? "Saving..." : "Save Changes",
                            isLoading: viewModel.isSaving
                        ) {
                            Task {
                                await viewModel.saveChanges()
                            }
                        }
                        .padding(.horizontal, 16)

                        // Success Message
                        if viewModel.showSuccess {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Changes saved successfully!")
                                    .font(.system(size: 14))
                                    .foregroundColor(.green)
                            }
                            .transition(.opacity)
                        }

                        // Actions Section
                        SettingsSection(title: "Actions") {
                            VStack(spacing: 0) {
                                SettingsActionRow(
                                    icon: "person.2.fill",
                                    title: "Meet the Planners"
                                ) {
                                    showMeetThePlanners = true
                                }

                                Divider()
                                    .padding(.leading, 44)

                                SettingsActionRow(
                                    icon: "square.and.arrow.up",
                                    title: "Share App",
                                    action: viewModel.shareApp
                                )

                                Divider()
                                    .padding(.leading, 44)

                                SettingsActionRow(
                                    icon: "arrow.clockwise",
                                    title: "Restore Purchases",
                                    isLoading: viewModel.isRestoringPurchases
                                ) {
                                    Task {
                                        await viewModel.restorePurchases()
                                    }
                                }
                            }
                        }

                        // Developer/Testing Section
                        SettingsSection(title: "Developer") {
                            VStack(spacing: 0) {
                                SettingsActionRow(
                                    icon: "arrow.counterclockwise",
                                    title: "Restart Onboarding",
                                    isDestructive: false
                                ) {
                                    Task {
                                        await viewModel.restartOnboarding()
                                        // Auth state change will redirect to onboarding
                                    }
                                }
                            }
                        }

                        // App Info
                        VStack(spacing: 8) {
                            Text("Daily I Do")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: Constants.Colors.secondaryText))

                            Text("Version 1.0.0")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: Constants.Colors.secondaryText).opacity(0.7))
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        HapticManager.shared.buttonTap()
                        onDone?()
                    }
                    .foregroundColor(Color(hex: Constants.Colors.accent))
                }
            }
            .onAppear {
                viewModel.loadUserData()
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .sheet(isPresented: $showMeetThePlanners) {
                MeetThePlannersView()
            }
        }
    }

    private func saveCouplePhoto(_ image: UIImage) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photoPath = documentsPath.appendingPathComponent("couple_photo.jpg")

        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: photoPath)
            UserDefaults.standard.set(photoPath.path, forKey: "couplePhotoPath")
            HapticManager.shared.success()
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                .tracking(0.5)
                .padding(.horizontal, 16)

            VStack {
                content
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: Constants.Colors.cardBackground))
            )
            .padding(.horizontal, 16)
        }
    }
}

struct SettingsActionRow: View {
    let icon: String
    let title: String
    var isDestructive: Bool = false
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.buttonTap()
            action()
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(isDestructive ? .red : Color(hex: Constants.Colors.primaryText))
                    .frame(width: 28)

                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(isDestructive ? .red : Color(hex: Constants.Colors.primaryText))

                Spacer()

                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: Constants.Colors.secondaryText).opacity(0.5))
                }
            }
            .padding(.vertical, 14)
        }
        .disabled(isLoading)
    }
}

#Preview {
    SettingsView()
}
