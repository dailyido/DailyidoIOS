import SwiftUI

struct PlanRevealView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var isOnboardingComplete: Bool

    // Staggered animation states
    @State private var showTop = false
    @State private var showFeatures = false
    @State private var showQuote = false
    @State private var showButton = false

    private let accentColor = Color(hex: Constants.Colors.accent)
    private let primaryColor = Color(hex: Constants.Colors.buttonPrimary)
    private let secondaryColor = Color(hex: Constants.Colors.secondaryText)

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // MARK: - Top Section (Personalization)
                topSection
                    .opacity(showTop ? 1 : 0)
                    .offset(y: showTop ? 0 : 20)

                // MARK: - Middle Section (Value Stack)
                valueStackSection
                    .opacity(showFeatures ? 1 : 0)
                    .offset(y: showFeatures ? 0 : 20)
                    .padding(.top, 32)

                // MARK: - Social Proof Section
                socialProofSection
                    .opacity(showQuote ? 1 : 0)
                    .offset(y: showQuote ? 0 : 20)
                    .padding(.top, 28)

                // MARK: - CTA Button
                PrimaryButton(title: "Let's Start Planning!") {
                    Task {
                        await viewModel.completeOnboarding()
                        isOnboardingComplete = true
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
                .padding(.bottom, 48)
                .opacity(showButton ? 1 : 0)
            }
            .padding(.top, 24)
        }
        .background(backgroundLayer)
        .onAppear {
            startAnimationSequence()
        }
    }

    // MARK: - Top Section

    private var topSection: some View {
        VStack(spacing: 8) {
            if viewModel.doesntKnowDate {
                // No date version
                Text("Congratulations on Your Engagement!")
                    .font(.custom("CormorantGaramond-Bold", size: 32))
                    .foregroundColor(primaryColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Text("\(viewModel.name) & \(viewModel.partnerName)")
                    .font(.custom("CormorantGaramond-Bold", size: 24))
                    .foregroundColor(accentColor)
                    .padding(.top, 4)
            } else {
                // Has date version
                Text("\(viewModel.name) & \(viewModel.partnerName)")
                    .font(.custom("CormorantGaramond-Bold", size: 28))
                    .foregroundColor(primaryColor)

                // Days countdown
                Text("\(viewModel.daysUntilWedding) Days to Go!")
                    .font(.custom("CormorantGaramond-Bold", size: 42))
                    .foregroundColor(primaryColor)

                // Sunset info (only show if we have location)
                if let sunsetTime = viewModel.sunsetTime, !viewModel.doesntKnowLocation {
                    HStack(spacing: 6) {
                        Image(systemName: "sun.horizon.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: Constants.Colors.accent))

                        Text("Sunset on \(formattedWeddingDate): \(sunsetTime)")
                            .font(.system(size: 15))
                            .foregroundColor(secondaryColor)
                    }
                    .padding(.top, 4)
                }
            }
        }
    }

    // MARK: - Value Stack Section

    private var valueStackSection: some View {
        VStack(spacing: 20) {
            if viewModel.doesntKnowDate {
                // No date version
                Text("We have curated a list of planning tips and fun facts while you work on setting your date!")
                    .font(.system(size: 17))
                    .foregroundColor(secondaryColor)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)

                Text("Once you pick your date, add the details in settings for your custom day by day calendar.")
                    .font(.system(size: 15))
                    .foregroundColor(secondaryColor.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 32)
                    .padding(.top, 4)

                // Feature bullets
                VStack(alignment: .leading, spacing: 14) {
                    featureRow(text: "General planning tips & fun facts")

                    if viewModel.isTentedWedding {
                        featureRow(text: "Tented wedding expertise included")
                    }

                    featureRow(text: "Smart checklist organized by priority")

                    featureRow(text: "Expert guidance from top wedding planners")

                    featureRow(text: "Add your date anytime in settings")
                }
                .padding(.horizontal, 32)
                .padding(.top, 12)
            } else {
                // Has date version
                Text("Your Custom Wedding Countdown is Ready")
                    .font(.custom("CormorantGaramond-Bold", size: 28))
                    .foregroundColor(primaryColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                // Feature bullets
                VStack(alignment: .leading, spacing: 14) {
                    featureRow(text: "\(viewModel.daysUntilWedding) daily tips curated for your timeline")

                    if viewModel.isTentedWedding {
                        featureRow(text: "Tented wedding expertise included")
                    }

                    featureRow(text: "Smart checklist organized by priority")

                    featureRow(text: "Daily reminders so nothing falls through the cracks")

                    featureRow(text: "Expert guidance from top wedding planners")
                }
                .padding(.horizontal, 32)
                .padding(.top, 8)
            }
        }
    }

    private func featureRow(text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18))
                .foregroundColor(accentColor)

            Text(text)
                .font(.system(size: 16))
                .foregroundColor(primaryColor)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Social Proof Section

    private var socialProofSection: some View {
        VStack(spacing: 10) {
            // Quote
            Text("\"I actually look forward to opening this app every morning. It makes planning feel manageable instead of overwhelming.\"")
                .font(.system(size: 14, weight: .regular))
                .italic()
                .foregroundColor(secondaryColor)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .padding(.horizontal, 16)

            // Attribution
            Text("— Sarah, getting married Sept '26")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(accentColor)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(accentColor.opacity(0.06))
        )
        .padding(.horizontal, 24)
    }

    // MARK: - Background

    private var backgroundLayer: some View {
        ZStack {
            Color(hex: Constants.Colors.background)

            // Top gradient orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [accentColor.opacity(0.1), accentColor.opacity(0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 250
                    )
                )
                .frame(width: 500, height: 500)
                .offset(y: -200)
                .blur(radius: 60)

            // Bottom accent
            Circle()
                .fill(
                    RadialGradient(
                        colors: [accentColor.opacity(0.06), accentColor.opacity(0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 360)
                .offset(y: 400)
                .blur(radius: 50)
        }
        .ignoresSafeArea()
    }

    // MARK: - Helpers

    private var formattedWeddingDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: viewModel.weddingDate)
    }

    // MARK: - Animations

    private func startAnimationSequence() {
        // Top section
        withAnimation(.easeOut(duration: 0.5)) {
            showTop = true
        }

        // Features
        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
            showFeatures = true
        }

        // Quote
        withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
            showQuote = true
        }

        // Button
        withAnimation(.easeOut(duration: 0.4).delay(0.7)) {
            showButton = true
        }

        // Success haptic
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            HapticManager.shared.success()
        }
    }
}

#Preview {
    PlanRevealView(viewModel: OnboardingViewModel(), isOnboardingComplete: .constant(false))
}
