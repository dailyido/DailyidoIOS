import SwiftUI
import StoreKit

struct RatingRequestView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.requestReview) var requestReview
    @State private var hasShownRatingPrompt = false

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: max(40, geometry.size.height * 0.12))

                    // Icon with stars
                    ZStack {
                        Circle()
                            .fill(Color(hex: Constants.Colors.accent).opacity(0.1))
                            .frame(width: 120, height: 120)

                        HStack(spacing: 4) {
                            ForEach(0..<5, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color(hex: Constants.Colors.accent))
                            }
                        }
                    }
                    .padding(.bottom, 40)

                    // Title
                    Text("We'd love a 5-star rating!")
                        .font(.custom("CormorantGaramond-Bold", size: 34))
                        .foregroundColor(Color(hex: Constants.Colors.buttonPrimary))
                        .multilineTextAlignment(.center)
                        .padding(.top, 28)

                    // Description
                    Text("Ratings help other engaged couples discover us. Would you mind leaving a quick rating?")
                        .font(.system(size: 17))
                        .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 32)
                        .padding(.top, 16)

                    // Additional note
                    Text("It only takes a second!")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color(hex: Constants.Colors.accent))
                        .padding(.top, 12)

                    Spacer()
                        .frame(height: max(40, geometry.size.height * 0.12))

                    // Continue button - first tap shows rating, second tap advances
                    PrimaryButton(title: "Continue") {
                        if !hasShownRatingPrompt {
                            requestReview()
                            hasShownRatingPrompt = true
                        } else {
                            viewModel.nextStep()
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
    RatingRequestView(viewModel: OnboardingViewModel())
}
