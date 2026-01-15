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
                        Spacer()
                            .frame(height: geometry.size.height * 0.08)

                        VStack(spacing: 24) {
                            // App icon/logo
                            ZStack {
                                Circle()
                                    .fill(accentColor.opacity(0.15))
                                    .frame(width: 80, height: 80)

                                Image(systemName: "heart.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(accentColor)
                            }
                            .padding(.bottom, 8)

                            // Welcome headline
                            Text("Welcome to Daily I Do")
                                .font(.custom("CormorantGaramond-Bold", size: 32))
                                .foregroundColor(primaryColor)
                                .multilineTextAlignment(.center)

                            Text("your new stress-free wedding planning app")
                                .font(.system(size: 16))
                                .foregroundColor(secondaryText)
                                .multilineTextAlignment(.center)

                            // Divider
                            Rectangle()
                                .fill(accentColor.opacity(0.3))
                                .frame(width: 40, height: 2)
                                .padding(.vertical, 8)

                            // Main description
                            Text("This isn't a checklist you'll ignore—it's a daily nudge that keeps you moving forward without the overwhelm.")
                                .font(.system(size: 16))
                                .foregroundColor(primaryColor)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .padding(.horizontal, 24)

                            // Each day section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Each day, you'll get:")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(primaryColor)

                                BulletPoint(text: "One clear planning tip")
                                BulletPoint(text: "Zero fluff")
                                BulletPoint(text: "Exactly what matters right now")
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 40)
                            .padding(.top, 8)

                            // Calm voice
                            Text("Think of this as your calm voice in the chaos.")
                                .font(.custom("CormorantGaramond-SemiBold", size: 20))
                                .foregroundColor(primaryColor)
                                .multilineTextAlignment(.center)
                                .padding(.top, 16)

                            // Final call to action text
                            Text("Open it daily. Do the thing.\nGet back to living your life.")
                                .font(.system(size: 15))
                                .foregroundColor(secondaryText)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .padding(.top, 8)
                        }
                        .padding(.horizontal, 24)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)

                        Spacer()
                            .frame(height: 40)

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
                .padding(.top, 3)

            Text(text)
                .font(.system(size: 16))
                .foregroundColor(primaryColor)
        }
    }
}

#Preview {
    IntroView(viewModel: OnboardingViewModel())
}
