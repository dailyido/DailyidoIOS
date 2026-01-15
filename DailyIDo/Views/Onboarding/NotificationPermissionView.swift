import SwiftUI

struct NotificationPermissionView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: max(40, geometry.size.height * 0.1))

                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color(hex: Constants.Colors.accent).opacity(0.1))
                            .frame(width: 120, height: 120)

                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 50))
                            .foregroundColor(Color(hex: Constants.Colors.illustrationTint))
                    }
                    .padding(.bottom, 24)

                    // Title
                    Text("Stay on track")
                        .font(.custom("CormorantGaramond-Bold", size: 34))
                        .foregroundColor(Color(hex: Constants.Colors.buttonPrimary))
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)

                    // Benefits list
                    VStack(alignment: .leading, spacing: 20) {
                        NotificationBenefit(
                            icon: "sun.max.fill",
                            text: "Get your daily wedding tip every morning"
                        )

                        NotificationBenefit(
                            icon: "flame.fill",
                            text: "Keep your planning streak alive"
                        )

                        NotificationBenefit(
                            icon: "star.fill",
                            text: "Never miss important wedding milestones"
                        )
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 24)

                    Spacer()
                        .frame(height: max(40, geometry.size.height * 0.1))

                    // Continue button
                    PrimaryButton(title: "Enable Notifications") {
                        Task {
                            await viewModel.requestNotificationPermission()
                        }
                    }
                    .padding(.horizontal, 24)

                    // Skip option
                    Button(action: {
                        HapticManager.shared.buttonTap()
                        viewModel.nextStep()
                    }) {
                        Text("Maybe Later")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 48)
                }
                .frame(minHeight: geometry.size.height)
            }
        }
    }
}

struct NotificationBenefit: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(Color(hex: Constants.Colors.accent))
                .frame(width: 36)

            Text(text)
                .font(.system(size: 17))
                .foregroundColor(Color(hex: Constants.Colors.primaryText))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    NotificationPermissionView(viewModel: OnboardingViewModel())
}
