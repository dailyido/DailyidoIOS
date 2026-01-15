import SwiftUI

struct PhilosophyView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    // Animation states
    @State private var showContent = false

    // Design tokens
    private let primaryColor = Color(hex: Constants.Colors.buttonPrimary)
    private let accentColor = Color(hex: Constants.Colors.accent)
    private let secondaryText = Color(hex: Constants.Colors.secondaryText)

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Match other onboarding screens
                Color(hex: Constants.Colors.background).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: geometry.size.height * 0.1)

                        // Main content card
                        VStack(spacing: 24) {
                            // Label
                            Text("RESEARCH SHOWS")
                                .font(.system(size: 12, weight: .medium))
                                .tracking(2)
                                .foregroundColor(secondaryText.opacity(0.6))

                            // The big stat
                            HStack(alignment: .top, spacing: 2) {
                                Text("83")
                                    .font(.system(size: 120, weight: .light))
                                    .foregroundColor(primaryColor)

                                Text("%")
                                    .font(.system(size: 36, weight: .light))
                                    .foregroundColor(accentColor)
                                    .padding(.top, 16)
                            }

                            Text("of couples")
                                .font(.custom("CormorantGaramond-Medium", size: 22))
                                .foregroundColor(secondaryText)

                            // Divider
                            Rectangle()
                                .fill(accentColor.opacity(0.3))
                                .frame(width: 40, height: 2)
                                .padding(.vertical, 8)

                            // Message
                            Text("find that planning\nbit by bit\nlowers stress")
                                .font(.custom("CormorantGaramond-Medium", size: 28))
                                .foregroundColor(primaryColor)
                                .multilineTextAlignment(.center)
                                .lineSpacing(6)

                            // Tagline
                            Text("One small step each day.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(secondaryText.opacity(0.5))
                                .padding(.top, 16)
                        }
                        .padding(.horizontal, 32)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)

                        Spacer()
                            .frame(height: 60)

                        // Continue button
                        PrimaryButton(title: "Continue") {
                            viewModel.nextStep()
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 48)
                        .opacity(showContent ? 1 : 0)
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                showContent = true
            }
        }
    }
}

#Preview {
    PhilosophyView(viewModel: OnboardingViewModel())
}
