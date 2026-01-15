import SwiftUI

enum PlanningFeeling: String {
    case gotThis = "gotThis"
    case someStress = "someStress"
    case overwhelmed = "overwhelmed"
}

struct PreparednessView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var showQuote = false
    @State private var selectedFeeling: PlanningFeeling?

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: max(40, geometry.size.height * 0.1))

                    if !showQuote {
                        // Question view
                        VStack(spacing: 32) {
                            // Icon
                            ZStack {
                                Circle()
                                    .fill(Color(hex: Constants.Colors.accent).opacity(0.1))
                                    .frame(width: 100, height: 100)

                                Image(systemName: "heart.circle")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color(hex: Constants.Colors.illustrationTint))
                            }

                            // Title
                            Text("How's wedding planning feeling right now?")
                                .font(.custom("CormorantGaramond-Bold", size: 34))
                                .foregroundColor(Color(hex: Constants.Colors.buttonPrimary))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)

                            // Option buttons - stacked vertically
                            VStack(spacing: 12) {
                                OptionButton(title: "I've got this", isSelected: false) {
                                    selectedFeeling = .gotThis
                                    viewModel.selectPreparedness(true)
                                    withAnimation {
                                        showQuote = true
                                    }
                                }

                                OptionButton(title: "Mostly okay, some stress", isSelected: false) {
                                    selectedFeeling = .someStress
                                    viewModel.selectPreparedness(true)
                                    withAnimation {
                                        showQuote = true
                                    }
                                }

                                OptionButton(title: "Honestly? Overwhelmed", isSelected: false) {
                                    selectedFeeling = .overwhelmed
                                    viewModel.selectPreparedness(false)
                                    withAnimation {
                                        showQuote = true
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    } else {
                        // Encouraging response view
                        VStack(spacing: 24) {
                            // Icon
                            ZStack {
                                Circle()
                                    .fill(Color(hex: Constants.Colors.accent).opacity(0.1))
                                    .frame(width: 100, height: 100)

                                Image(systemName: "sparkles")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color(hex: Constants.Colors.illustrationTint))
                            }

                            switch selectedFeeling {
                            case .gotThis:
                                Text("Love the confidence!")
                                    .font(.custom("CormorantGaramond-Bold", size: 34))
                                    .foregroundColor(Color(hex: Constants.Colors.buttonPrimary))
                                    .multilineTextAlignment(.center)

                                Text("We'll help you stay on track and discover tips you might not have thought of yet.")
                                    .font(.system(size: 17))
                                    .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)

                            case .someStress:
                                Text("Totally normal!")
                                    .font(.custom("CormorantGaramond-Bold", size: 34))
                                    .foregroundColor(Color(hex: Constants.Colors.buttonPrimary))
                                    .multilineTextAlignment(.center)

                                Text("A little stress means you care. We'll help you tackle things one day at a time so nothing slips through the cracks.")
                                    .font(.system(size: 17))
                                    .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)

                            case .overwhelmed, .none:
                                Text("You're not alone!")
                                    .font(.custom("CormorantGaramond-Bold", size: 34))
                                    .foregroundColor(Color(hex: Constants.Colors.buttonPrimary))
                                    .multilineTextAlignment(.center)

                                Text("Most couples feel this way. That's exactly why we created Daily I Do — to guide you through it, one tip at a time.")
                                    .font(.system(size: 17))
                                    .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }
                        }
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }

                    Spacer()
                        .frame(height: max(40, geometry.size.height * 0.1))

                    // Continue button (only visible after selection)
                    if showQuote {
                        PrimaryButton(title: "Continue") {
                            viewModel.nextStep()
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 48)
                        .transition(.opacity)
                    }
                }
                .frame(minHeight: geometry.size.height)
            }
        }
    }
}

#Preview {
    PreparednessView(viewModel: OnboardingViewModel())
}
