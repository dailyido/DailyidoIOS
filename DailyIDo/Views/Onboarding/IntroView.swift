import SwiftUI

struct IntroView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    @State private var showContent = false

    private let primaryColor = Color(hex: Constants.Colors.buttonPrimary)
    private let accentColor = Color(hex: Constants.Colors.accent)
    private let secondaryText = Color(hex: Constants.Colors.secondaryText)

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(hex: Constants.Colors.background).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        VStack(spacing: 16) {
                            // App icon/logo
                            ZStack {
                                Circle()
                                    .fill(accentColor.opacity(0.15))
                                    .frame(width: 70, height: 70)

                                Image(systemName: "heart.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(accentColor)
                            }
                            .padding(.bottom, 4)

                            // Welcome headline
                            Text("Welcome to Daily I Do")
                                .font(.custom("CormorantGaramond-Bold", size: 30))
                                .foregroundColor(primaryColor)
                                .multilineTextAlignment(.center)

                            Text("Your new stress-free wedding planning app")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(secondaryText)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 24)

                        // Divider
                        Rectangle()
                            .fill(accentColor.opacity(0.3))
                            .frame(width: 40, height: 2)
                            .padding(.vertical, 20)

                        // Main content - left aligned
                        VStack(alignment: .leading, spacing: 16) {
                            // Main description
                            Text("This isn't a checklist you'll ignore, it's a daily nudge that keeps you moving forward without feeling overwhelmed.")
                                .font(.system(size: 17))
                                .foregroundColor(primaryColor)
                                .lineSpacing(4)

                            // Each day section
                            Text("Each day, you'll get:")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(primaryColor)
                                .padding(.top, 8)

                            VStack(alignment: .leading, spacing: 12) {
                                BulletPoint(text: "One clear planning tip")
                                BulletPoint(text: "Zero fluff")
                                BulletPoint(text: "Exactly what matters right now")
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 32)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)

                        // Divider
                        Rectangle()
                            .fill(accentColor.opacity(0.3))
                            .frame(width: 40, height: 2)
                            .padding(.vertical, 20)
                            .opacity(showContent ? 1 : 0)

                        // Calm voice - centered
                        Text("Think of us as your calm voice\nin the chaos.")
                            .font(.custom("CormorantGaramond-Bold", size: 24))
                            .foregroundColor(primaryColor)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 32)
                            .padding(.top, 4)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)

                        // Final call to action text - centered and bigger
                        Text("Open it daily. Do the thing.\nGet back to living your life.")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(secondaryText)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 32)
                            .padding(.top, 8)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)

                        Spacer(minLength: 24)

                        // CTA Button
                        PrimaryButton(title: "Let's plan this wedding") {
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

struct BulletPoint: View {
    let text: String

    private let accentColor = Color(hex: Constants.Colors.accent)
    private let primaryColor = Color(hex: Constants.Colors.buttonPrimary)

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(accentColor)
                .padding(.top, 4)

            Text(text)
                .font(.system(size: 17))
                .foregroundColor(primaryColor)
        }
    }
}

#Preview {
    IntroView(viewModel: OnboardingViewModel())
}
