import SwiftUI

struct LongEngagementTutorialView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var isOnboardingComplete: Bool

    @State private var showContent = false
    @State private var showButton = false

    private let primaryColor = Color(hex: Constants.Colors.buttonPrimary)
    private let accentColor = Color(hex: Constants.Colors.accent)
    private let secondaryColor = Color(hex: Constants.Colors.secondaryText)

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: max(40, geometry.size.height * 0.1))

                    // Calendar icon
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 64))
                        .foregroundColor(accentColor)
                        .opacity(showContent ? 1 : 0)
                        .scaleEffect(showContent ? 1 : 0.8)

                    // Title
                    Text("You're Ahead of the Game!")
                        .font(.custom("CormorantGaramond-Bold", size: 32))
                        .foregroundColor(primaryColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)

                    // Main message
                    VStack(spacing: 16) {
                        Text("You're over 440 days out—perfect for big-picture planning.")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(primaryColor)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("More detailed, step-by-step tips will unlock as you get closer (around 15 months out).")
                            .font(.system(size: 16))
                            .foregroundColor(secondaryColor)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 20)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)

                    // Info card
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 20))
                                .foregroundColor(accentColor)

                            Text("Focus on the fun stuff first!")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(primaryColor)

                            Spacer()
                        }

                        Text("Venue tours, photographer research, and dreaming about your day. The nitty-gritty details can wait.")
                            .font(.system(size: 14))
                            .foregroundColor(secondaryColor)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(accentColor.opacity(0.08))
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)

                    Spacer()
                        .frame(height: max(40, geometry.size.height * 0.1))

                    // CTA Button
                    PrimaryButton(title: "Got It, Let's Go!") {
                        Task {
                            await viewModel.completeOnboarding()
                            isOnboardingComplete = true
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                    .opacity(showButton ? 1 : 0)
                }
                .frame(minHeight: geometry.size.height)
            }
        }
        .background(backgroundLayer)
        .onAppear {
            startAnimationSequence()
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            Color(hex: Constants.Colors.background)

            // Soft gradient orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [accentColor.opacity(0.12), accentColor.opacity(0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(y: -100)
                .blur(radius: 60)
        }
        .ignoresSafeArea()
    }

    private func startAnimationSequence() {
        withAnimation(.easeOut(duration: 0.6)) {
            showContent = true
        }

        withAnimation(.easeOut(duration: 0.4).delay(0.5)) {
            showButton = true
        }
    }
}

#Preview {
    LongEngagementTutorialView(viewModel: OnboardingViewModel(), isOnboardingComplete: .constant(false))
}
