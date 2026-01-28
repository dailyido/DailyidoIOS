import SwiftUI

struct TentedQuestionView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: max(40, geometry.size.height * 0.15))

                    // Icon - Wedding tent/marquee
                    ZStack {
                        Circle()
                            .fill(Color(hex: Constants.Colors.accent).opacity(0.1))
                            .frame(width: 100, height: 100)

                        WeddingTentIcon()
                            .fill(Color(hex: Constants.Colors.illustrationTint))
                            .frame(width: 50, height: 40)
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

// Custom wedding tent/marquee shape - elegant sailcloth style
struct WeddingTentIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width
        let height = rect.height

        // Elegant sailcloth tent with swooping canopy
        // Start at bottom left
        path.move(to: CGPoint(x: 0, y: height))

        // Left pole (straight up)
        path.addLine(to: CGPoint(x: width * 0.08, y: height * 0.4))

        // Canopy swoops up to center peak
        path.addQuadCurve(
            to: CGPoint(x: width * 0.5, y: height * 0.05),
            control: CGPoint(x: width * 0.25, y: height * 0.35)
        )

        // Canopy swoops down to right
        path.addQuadCurve(
            to: CGPoint(x: width * 0.92, y: height * 0.4),
            control: CGPoint(x: width * 0.75, y: height * 0.35)
        )

        // Right pole (straight down)
        path.addLine(to: CGPoint(x: width, y: height))

        // Bottom edge
        path.addLine(to: CGPoint(x: 0, y: height))

        path.closeSubpath()

        // Left flag
        path.move(to: CGPoint(x: width * 0.08, y: height * 0.4))
        path.addLine(to: CGPoint(x: width * 0.08, y: height * 0.22))
        path.addLine(to: CGPoint(x: width * 0.18, y: height * 0.28))
        path.addLine(to: CGPoint(x: width * 0.08, y: height * 0.34))
        path.closeSubpath()

        // Center flag
        path.move(to: CGPoint(x: width * 0.5, y: height * 0.05))
        path.addLine(to: CGPoint(x: width * 0.5, y: -height * 0.12))
        path.addLine(to: CGPoint(x: width * 0.62, y: -height * 0.05))
        path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.02))
        path.closeSubpath()

        // Right flag
        path.move(to: CGPoint(x: width * 0.92, y: height * 0.4))
        path.addLine(to: CGPoint(x: width * 0.92, y: height * 0.22))
        path.addLine(to: CGPoint(x: width * 1.02, y: height * 0.28))
        path.addLine(to: CGPoint(x: width * 0.92, y: height * 0.34))
        path.closeSubpath()

        return path
    }
}

#Preview {
    TentedQuestionView(viewModel: OnboardingViewModel())
}
