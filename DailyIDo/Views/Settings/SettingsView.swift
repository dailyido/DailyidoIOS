import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showMeetThePlanners = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: Constants.Colors.background)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
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

                        // Wedding Details Section
                        SettingsSection(title: "Wedding Details") {
                            VStack(spacing: 16) {
                                // Wedding Date
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Wedding Date")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(hex: Constants.Colors.secondaryText))

                                    DatePicker(
                                        "",
                                        selection: $viewModel.weddingDate,
                                        displayedComponents: .date
                                    )
                                    .datePickerStyle(.compact)
                                    .tint(Color(hex: Constants.Colors.accent))
                                    .labelsHidden()
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

                                Divider()
                                    .padding(.leading, 44)

                                SettingsActionRow(
                                    icon: "rectangle.portrait.and.arrow.right",
                                    title: "Sign Out",
                                    isDestructive: true
                                ) {
                                    Task {
                                        await viewModel.signOut()
                                        dismiss()
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
                                        dismiss()
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
                        dismiss()
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
