import SwiftUI

struct NameInputView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: max(40, geometry.size.height * 0.08))

                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color(hex: Constants.Colors.accent).opacity(0.1))
                            .frame(width: 80, height: 80)

                        Image(systemName: "person.fill")
                            .font(.system(size: 32))
                            .foregroundColor(Color(hex: Constants.Colors.illustrationTint))
                    }

                    // Title
                    Text("What's your name?")
                        .font(.custom("CormorantGaramond-Bold", size: 34))
                        .foregroundColor(Color(hex: Constants.Colors.buttonPrimary))
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)

                    // Input field
                    TextInputField(placeholder: "Your name", text: $viewModel.name, autoFocus: true)
                        .padding(.horizontal, 24)
                        .padding(.top, 24)

                    Spacer()
                        .frame(height: 32)

                    // Continue button
                    PrimaryButton(title: "Continue", isDisabled: !viewModel.canContinue) {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        viewModel.nextStep()
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }
                .frame(minHeight: geometry.size.height)
            }
        }
    }
}

struct PartnerNameInputView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: max(40, geometry.size.height * 0.08))

                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color(hex: Constants.Colors.accent).opacity(0.1))
                            .frame(width: 80, height: 80)

                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(Color(hex: Constants.Colors.illustrationTint))
                    }

                    // Title
                    Text("What's your partner's name?")
                        .font(.custom("CormorantGaramond-Bold", size: 34))
                        .foregroundColor(Color(hex: Constants.Colors.buttonPrimary))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.top, 20)

                    // Input field
                    TextInputField(placeholder: "Partner's name", text: $viewModel.partnerName, autoFocus: true)
                        .padding(.horizontal, 24)
                        .padding(.top, 24)

                    Spacer()
                        .frame(height: 32)

                    // Continue button
                    PrimaryButton(title: "Continue", isDisabled: !viewModel.canContinue) {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        viewModel.nextStep()
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }
                .frame(minHeight: geometry.size.height)
            }
        }
    }
}

#Preview {
    NameInputView(viewModel: OnboardingViewModel())
}
