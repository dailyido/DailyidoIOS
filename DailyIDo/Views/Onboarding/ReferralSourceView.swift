import SwiftUI

struct ReferralSourceView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    private let primaryColor = Color(hex: Constants.Colors.buttonPrimary)
    private let secondaryText = Color(hex: Constants.Colors.secondaryText)

    private let sources = [
        ("Instagram", "camera.fill"),
        ("TikTok", "play.rectangle.fill"),
        ("Friend/Family", "person.2.fill"),
        ("Wedding Vendor", "storefront.fill"),
        ("Other", "ellipsis.circle.fill")
    ]

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Title
                        Text("How did you hear about Daily I Do?")
                            .font(.custom("CormorantGaramond-Bold", size: 28))
                            .foregroundColor(primaryColor)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 32)
                            .padding(.top, 24)

                        // Subtitle
                        Text("We'd love to know what brought you here!")
                            .font(.system(size: 16))
                            .foregroundColor(secondaryText)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 8)
                            .padding(.horizontal, 32)

                        // Options
                        VStack(spacing: 10) {
                            ForEach(sources, id: \.0) { source in
                                ReferralOptionButton(
                                    title: source.0,
                                    icon: source.1,
                                    isSelected: viewModel.referralSource == source.0,
                                    primaryColor: primaryColor
                                ) {
                                    HapticManager.shared.buttonTap()
                                    viewModel.referralSource = source.0
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .padding(.bottom, 16)
                    }
                }

                // Continue button pinned to bottom
                PrimaryButton(
                    title: "Continue",
                    isDisabled: viewModel.referralSource.isEmpty
                ) {
                    viewModel.nextStep()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .padding(.top, 8)
            }
        }
    }
}

struct ReferralOptionButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let primaryColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .white : primaryColor)
                    .frame(width: 24)

                Text(title)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(isSelected ? .white : primaryColor)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? primaryColor : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(primaryColor, lineWidth: isSelected ? 0 : 2)
            )
        }
    }
}

#Preview {
    ReferralSourceView(viewModel: OnboardingViewModel())
}
