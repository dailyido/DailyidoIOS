import SwiftUI

struct RemotePopupView: View {
    let popup: RemotePopup
    let onDismiss: () -> Void
    let onCTATap: () -> Void

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var shimmerOffset: CGFloat = -300
    @State private var iconScale: CGFloat = 0.8
    @State private var iconRotation: Double = -10
    @State private var floatingOffset: CGFloat = 0
    @State private var sparkleOpacity: Double = 0
    @State private var ringRotation: Double = 0

    // Elegant wedding palette
    private let blushPink = Color(red: 255/255, green: 228/255, blue: 235/255)
    private let champagneGold = Color(red: 212/255, green: 175/255, blue: 125/255)
    private let softRose = Color(red: 244/255, green: 194/255, blue: 194/255)
    private let ivory = Color(red: 255/255, green: 253/255, blue: 250/255)
    private let dustyRose = Color(red: 192/255, green: 134/255, blue: 134/255)
    private let darkBlue = Color(hex: Constants.Colors.buttonPrimary)

    // Dynamic icon based on popup content
    private var holidayIcon: String {
        let title = popup.title.lowercased()
        if title.contains("valentine") || title.contains("love") {
            return "heart.fill"
        } else if title.contains("christmas") || title.contains("holiday") {
            return "gift.fill"
        } else if title.contains("new year") {
            return "sparkles"
        } else if title.contains("thanksgiving") {
            return "leaf.fill"
        } else if title.contains("easter") {
            return "camera.macro"
        } else if title.contains("july") || title.contains("independence") {
            return "star.fill"
        } else if title.contains("halloween") {
            return "moon.stars.fill"
        } else {
            return "heart.circle.fill"
        }
    }

    var body: some View {
        ZStack {
            // Soft gradient background overlay
            LinearGradient(
                colors: [
                    Color.black.opacity(0.35),
                    Color(red: 45/255, green: 35/255, blue: 40/255).opacity(0.55)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .onTapGesture {
                HapticManager.shared.lightImpact()
                dismiss()
            }

            // Floating decorative elements
            FloatingSparklesView(sparkleOpacity: sparkleOpacity)

            // Main popup card
            VStack(spacing: 0) {
                // Close button - elegant style
                HStack {
                    Spacer()
                    Button(action: {
                        HapticManager.shared.buttonTap()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(dustyRose.opacity(0.6))
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(blushPink.opacity(0.5))
                            )
                    }
                }
                .padding(.top, 16)
                .padding(.trailing, 16)

                // Decorative top flourish
                HStack(spacing: 8) {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [champagneGold.opacity(0), champagneGold, champagneGold.opacity(0)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 50, height: 1)

                    Image(systemName: "sparkle")
                        .font(.system(size: 8))
                        .foregroundColor(champagneGold)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [champagneGold.opacity(0), champagneGold, champagneGold.opacity(0)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 50, height: 1)
                }
                .padding(.top, 4)

                // Holiday icon/illustration with decorative ring
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [softRose.opacity(0.3), softRose.opacity(0)],
                                center: .center,
                                startRadius: 25,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)

                    // Decorative rotating ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [champagneGold.opacity(0.4), champagneGold.opacity(0.8), champagneGold.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                        )
                        .frame(width: 90, height: 90)
                        .rotationEffect(.degrees(ringRotation))

                    // Custom illustration or fallback to icon
                    if let illustrationUrlString = popup.fullIllustrationUrl,
                       let illustrationUrl = URL(string: illustrationUrlString) {
                        // Custom illustration from storage
                        CachedAsyncImage(url: illustrationUrl) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 70, height: 70)
                                .clipShape(Circle())
                                .scaleEffect(iconScale)
                                .offset(y: floatingOffset)
                        } placeholder: {
                            // Show icon while loading
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [blushPink, softRose.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 70, height: 70)
                                .overlay(
                                    ProgressView()
                                        .tint(dustyRose)
                                )
                        }
                    } else {
                        // Fallback: Inner circle with SF Symbol icon
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [blushPink, softRose.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 70, height: 70)
                            .shadow(color: dustyRose.opacity(0.25), radius: 12, x: 0, y: 6)

                        // Holiday icon
                        Image(systemName: holidayIcon)
                            .font(.system(size: 30))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [dustyRose, Color(red: 170/255, green: 100/255, blue: 110/255)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .scaleEffect(iconScale)
                            .rotationEffect(.degrees(iconRotation))
                            .offset(y: floatingOffset)
                    }
                }
                .padding(.top, 16)

                // Image (if available)
                if let imageUrl = popup.imageUrl, let url = URL(string: imageUrl) {
                    CachedAsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(champagneGold.opacity(0.3), lineWidth: 1)
                            )
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(blushPink.opacity(0.3))
                            .frame(height: 120)
                            .overlay(
                                ProgressView()
                                    .tint(dustyRose)
                            )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                }

                // Title with elegant serif font
                Text(popup.title)
                    .font(.custom("CormorantGaramond-Bold", size: 28))
                    .foregroundColor(darkBlue)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                // Message
                Text(popup.message)
                    .font(.system(size: 15))
                    .foregroundColor(darkBlue.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 28)
                    .padding(.top, 12)

                // Elegant divider
                HStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { _ in
                        Circle()
                            .fill(champagneGold.opacity(0.4))
                            .frame(width: 4, height: 4)
                    }
                }
                .padding(.top, 20)

                // CTA Button (if available) - elegant style
                if let ctaText = popup.ctaText, !ctaText.isEmpty {
                    Button(action: {
                        HapticManager.shared.success()
                        onCTATap()
                        dismiss()
                    }) {
                        HStack(spacing: 8) {
                            Text(ctaText)
                                .font(.system(size: 16, weight: .semibold))

                            Image(systemName: "sparkles")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [dustyRose, Color(red: 170/255, green: 110/255, blue: 115/255)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: dustyRose.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                }

                // Bottom flourish
                HStack(spacing: 8) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 10))
                        .foregroundColor(champagneGold.opacity(0.5))
                        .rotationEffect(.degrees(-45))

                    Rectangle()
                        .fill(champagneGold.opacity(0.3))
                        .frame(width: 40, height: 1)

                    Image(systemName: "heart.fill")
                        .font(.system(size: 8))
                        .foregroundColor(dustyRose.opacity(0.5))

                    Rectangle()
                        .fill(champagneGold.opacity(0.3))
                        .frame(width: 40, height: 1)

                    Image(systemName: "leaf.fill")
                        .font(.system(size: 10))
                        .foregroundColor(champagneGold.opacity(0.5))
                        .rotationEffect(.degrees(45))
                        .scaleEffect(x: -1, y: 1)
                }
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
            .background(
                ZStack {
                    // Main card background
                    RoundedRectangle(cornerRadius: 28)
                        .fill(ivory)

                    // Subtle shimmer effect
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .clear,
                                    .white.opacity(0.5),
                                    .clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: shimmerOffset)
                        .mask(RoundedRectangle(cornerRadius: 28))

                    // Elegant border
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(
                            LinearGradient(
                                colors: [champagneGold.opacity(0.4), champagneGold.opacity(0.15)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                }
            )
            .padding(.horizontal, 24)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            // Entrance haptic
            HapticManager.shared.celebrationEntrance()

            // Card entrance animation
            withAnimation(.spring(response: 0.55, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }

            // Icon bounce in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5).delay(0.2)) {
                iconScale = 1.0
                iconRotation = 0
            }

            // Ring rotation
            withAnimation(.linear(duration: 25).repeatForever(autoreverses: false)) {
                ringRotation = 360
            }

            // Gentle floating animation for icon
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(0.3)) {
                floatingOffset = -5
            }

            // Shimmer effect
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: false).delay(0.5)) {
                shimmerOffset = 350
            }

            // Sparkles fade in
            withAnimation(.easeIn(duration: 0.8).delay(0.3)) {
                sparkleOpacity = 1.0
            }
        }
    }

    private func dismiss() {
        HapticManager.shared.celebrationDismiss()

        withAnimation(.easeOut(duration: 0.25)) {
            scale = 0.9
            opacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onDismiss()
        }
    }
}

// MARK: - Floating Sparkles Background

struct FloatingSparklesView: View {
    let sparkleOpacity: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<12, id: \.self) { index in
                    FloatingSparkle(
                        index: index,
                        screenSize: geometry.size
                    )
                }
            }
        }
        .opacity(sparkleOpacity)
        .ignoresSafeArea()
    }
}

struct FloatingSparkle: View {
    let index: Int
    let screenSize: CGSize

    @State private var yOffset: CGFloat = 0
    @State private var xOffset: CGFloat = 0
    @State private var sparkleOpacity: Double = 0
    @State private var rotation: Double = 0

    private let champagneGold = Color(red: 212/255, green: 175/255, blue: 125/255)
    private let softRose = Color(red: 244/255, green: 194/255, blue: 194/255)

    private var randomX: CGFloat {
        CGFloat.random(in: 20...(screenSize.width - 20))
    }

    private var randomY: CGFloat {
        CGFloat.random(in: 60...(screenSize.height - 60))
    }

    private var sparkleSize: CGFloat {
        CGFloat.random(in: 6...14)
    }

    private var sparkleColor: Color {
        [champagneGold.opacity(0.6), softRose.opacity(0.5), Color.white.opacity(0.4)].randomElement()!
    }

    var body: some View {
        Image(systemName: index % 3 == 0 ? "sparkle" : (index % 3 == 1 ? "star.fill" : "heart.fill"))
            .font(.system(size: sparkleSize))
            .foregroundColor(sparkleColor)
            .position(x: randomX + xOffset, y: randomY + yOffset)
            .opacity(sparkleOpacity)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                let delay = Double(index) * 0.15

                // Fade in
                withAnimation(.easeIn(duration: 0.6).delay(delay)) {
                    sparkleOpacity = Double.random(in: 0.3...0.7)
                }

                // Gentle float
                withAnimation(.easeInOut(duration: Double.random(in: 3...5)).repeatForever(autoreverses: true).delay(delay)) {
                    yOffset = CGFloat.random(in: -15...15)
                    xOffset = CGFloat.random(in: -10...10)
                }

                // Slow rotation
                withAnimation(.linear(duration: Double.random(in: 8...15)).repeatForever(autoreverses: false).delay(delay)) {
                    rotation = Bool.random() ? 360 : -360
                }

                // Twinkle effect
                withAnimation(.easeInOut(duration: Double.random(in: 1.5...2.5)).repeatForever(autoreverses: true).delay(delay + 1)) {
                    sparkleOpacity = Double.random(in: 0.2...0.5)
                }
            }
    }
}

#Preview {
    RemotePopupView(
        popup: RemotePopup(
            id: UUID(),
            popupType: "holiday",
            triggerDate: Date(),
            triggerDaysOut: nil,
            title: "Happy Valentine's Day! 💕",
            message: "Love is in the air! Wishing you and your partner a beautiful day filled with romance and joy.",
            imageUrl: nil,
            ctaText: "Celebrate",
            ctaAction: nil,
            isActive: true
        ),
        onDismiss: {},
        onCTATap: {}
    )
}
