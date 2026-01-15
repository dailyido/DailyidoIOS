import SwiftUI

struct WelcomeView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: max(20, geometry.size.height * 0.05))

                    // Planners photo
                    Image("planners")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal, 56)

                    // "Hi!" greeting
                    Text("Hi!")
                        .font(.custom("CormorantGaramond-Bold", size: 30))
                        .foregroundColor(Color(hex: Constants.Colors.buttonPrimary))
                        .padding(.top, 16)

                    // "We're Heather & Jamie!"
                    Text("We're Heather & Jamie!")
                        .font(.custom("CormorantGaramond-Bold", size: 26))
                        .foregroundColor(Color(hex: Constants.Colors.buttonPrimary))
                        .padding(.top, 2)

                    // Description
                    Text("Longtime wedding planners who've seen it all (truly!). We've curated daily planning tips from our 25+ years of experience to help you plan your wedding with confidence, clarity and a little bit of fun!")
                        .font(.system(size: 17))
                        .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 28)
                        .padding(.top, 14)

                    // Excited message
                    Text("We are excited to be a part of your wedding planning journey!")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                        .padding(.top, 10)

                    // Signatures
                    HStack(spacing: 16) {
                        Image("heather_signature")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 50)

                        Image(systemName: "heart.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: Constants.Colors.accent))

                        Image("jamie_signature")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 60)
                    }
                    .padding(.top, 14)

                    Spacer()
                        .frame(height: 24)

                    // Button
                    PrimaryButton(title: "Let's Do This!") {
                        viewModel.nextStep()
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }
                .frame(minHeight: geometry.size.height)
            }
        }
        .background(Color(hex: Constants.Colors.background))
    }
}

#Preview {
    WelcomeView(viewModel: OnboardingViewModel())
}
