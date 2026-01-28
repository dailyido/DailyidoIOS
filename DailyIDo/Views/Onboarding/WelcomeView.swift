import SwiftUI

struct WelcomeView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    // Calculate dynamic image height based on screen size
    private func imageHeight(for screenHeight: CGFloat) -> CGFloat {
        // Reserve space for text content (~350pt) and button (~100pt)
        // Give remaining space to image with a max cap
        let reservedSpace: CGFloat = 450
        let availableForImage = screenHeight - reservedSpace
        return min(max(availableForImage, 120), 220) // Min 120, max 220
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Planners photo - dynamically sized
                        Image("planners")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: imageHeight(for: geometry.size.height))
                            .padding(.horizontal, 60)
                            .padding(.top, 16)

                        // "Hi!" greeting
                        Text("Hi!")
                            .font(.custom("CormorantGaramond-Bold", size: 26))
                            .foregroundColor(Color(hex: Constants.Colors.buttonPrimary))
                            .padding(.top, 10)

                        // "We're Jamie & Heather!"
                        Text("We're Jamie & Heather!")
                            .font(.custom("CormorantGaramond-Bold", size: 28))
                            .foregroundColor(Color(hex: Constants.Colors.buttonPrimary))
                            .padding(.top, 2)

                        // Description
                        Text("Longtime wedding planners who've seen it all (truly!). We've curated daily planning tips from our 25+ years of experience to help you plan your wedding with confidence, clarity and a little bit of fun!")
                            .font(.system(size: 17))
                            .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 28)
                            .padding(.top, 10)

                        // Excited message
                        Text("We are excited to be a part of your wedding planning journey!")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 28)
                            .padding(.top, 8)

                        // Signatures
                        HStack(spacing: 14) {
                            Image("jamie_signature")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 58)
                                .offset(y: 4)

                            Image(systemName: "heart.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: Constants.Colors.accent))

                            Image("heather_signature")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 48)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 16)
                    }
                }

                // Button pinned to bottom
                PrimaryButton(title: "Let's Do This!") {
                    viewModel.nextStep()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .padding(.top, 8)
            }
        }
        .background(Color(hex: Constants.Colors.background))
    }
}

#Preview {
    WelcomeView(viewModel: OnboardingViewModel())
}
