import SwiftUI

struct TentedQuestionView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: max(40, geometry.size.height * 0.15))

                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color(hex: Constants.Colors.accent).opacity(0.1))
                            .frame(width: 100, height: 100)

                        Image(systemName: "tent.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Color(hex: Constants.Colors.illustrationTint))
                    }

                    // Title
                    Text("Is it a tented wedding?")
                        .font(.custom("CormorantGaramond-Bold", size: 34))
                        .foregroundColor(Color(hex: Constants.Colors.buttonPrimary))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.top, 28)

                    // Subtitle
                    Text("We have specific advice for tented weddings we want to make sure you get!")
                        .font(.system(size: 17))
                        .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 32)
                        .padding(.top, 12)

                    Spacer()
                        .frame(height: max(40, geometry.size.height * 0.15))

                    // Option buttons - stacked vertically
                    VStack(spacing: 12) {
                        OptionButton(title: "Yes", isSelected: viewModel.isTentedWedding) {
                            viewModel.selectTentedOption(true)
                        }

                        OptionButton(title: "No", isSelected: !viewModel.isTentedWedding && viewModel.currentStep > 6) {
                            viewModel.selectTentedOption(false)
                        }
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
    TentedQuestionView(viewModel: OnboardingViewModel())
}
