import SwiftUI

struct CelebrationPopup: View {
    let milestone: StreakMilestone
    let onDismiss: () -> Void

    @State private var showConfetti = false
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var ringRotation: Double = 0
    @State private var shimmerOffset: CGFloat = -200
    @State private var heartScale: CGFloat = 1.0

    // Elegant wedding palette
    private let blushPink = Color(red: 255/255, green: 228/255, blue: 235/255)
    private let champagneGold = Color(red: 212/255, green: 175/255, blue: 125/255)
    private let softRose = Color(red: 244/255, green: 194/255, blue: 194/255)
    private let ivory = Color(red: 255/255, green: 253/255, blue: 250/255)
    private let dustyRose = Color(red: 192/255, green: 134/255, blue: 134/255)
    private let darkBlue = Color(hex: Constants.Colors.buttonPrimary)

    var body: some View {
        ZStack {
            // Soft gradient background overlay
            LinearGradient(
                colors: [
                    Color.black.opacity(0.4),
                    Color(red: 45/255, green: 35/255, blue: 40/255).opacity(0.6)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .onTapGesture {
                HapticManager.shared.lightImpact()
                dismiss()
            }

            // Wedding confetti - hearts, sparkles, petals
            if showConfetti {
                WeddingConfettiView()
            }

            // Main popup card
            VStack(spacing: 0) {
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
                        .frame(width: 60, height: 1)

                    Image(systemName: "sparkle")
                        .font(.system(size: 10))
                        .foregroundColor(champagneGold)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [champagneGold.opacity(0), champagneGold, champagneGold.opacity(0)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 60, height: 1)
                }
                .padding(.top, 28)

                // Celebration icon - interlocking rings with hearts
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [softRose.opacity(0.4), softRose.opacity(0)],
                                center: .center,
                                startRadius: 30,
                                endRadius: 70
                            )
                        )
                        .frame(width: 140, height: 140)

                    // Decorative ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [champagneGold.opacity(0.6), champagneGold, champagneGold.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(ringRotation))

                    // Inner circle with heart
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [blushPink, softRose.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: dustyRose.opacity(0.3), radius: 15, x: 0, y: 8)

                    // Heart icon
                    Image(systemName: "heart.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [dustyRose, Color(red: 180/255, green: 100/255, blue: 110/255)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .scaleEffect(heartScale)
                }
                .padding(.top, 20)

                // "Day Streak" label
                Text("DAY STREAK")
                    .font(.system(size: 11, weight: .medium))
                    .tracking(3)
                    .foregroundColor(dustyRose)
                    .padding(.top, 16)

                // Streak count - elegant serif
                Text("\(milestone.days)")
                    .font(.custom("CormorantGaramond-Bold", size: 72))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [champagneGold, Color(red: 180/255, green: 140/255, blue: 90/255)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: champagneGold.opacity(0.3), radius: 10, x: 0, y: 4)
                    .padding(.top, -8)

                // Title with decorative elements
                HStack(spacing: 12) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 12))
                        .foregroundColor(champagneGold.opacity(0.6))
                        .rotationEffect(.degrees(-45))

                    Text(milestone.title)
                        .font(.custom("CormorantGaramond-SemiBold", size: 26))
                        .foregroundColor(darkBlue)

                    Image(systemName: "leaf.fill")
                        .font(.system(size: 12))
                        .foregroundColor(champagneGold.opacity(0.6))
                        .rotationEffect(.degrees(45))
                        .scaleEffect(x: -1, y: 1)
                }
                .padding(.top, 4)

                // Message
                Text(milestone.message)
                    .font(.system(size: 15))
                    .foregroundColor(darkBlue.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

                // Elegant divider
                HStack(spacing: 16) {
                    ForEach(0..<3, id: \.self) { _ in
                        Circle()
                            .fill(champagneGold.opacity(0.4))
                            .frame(width: 4, height: 4)
                    }
                }
                .padding(.top, 20)

                // Dismiss button - elegant style
                Button(action: {
                    HapticManager.shared.success()
                    dismiss()
                }) {
                    HStack(spacing: 8) {
                        Text("Keep Going")
                            .font(.system(size: 16, weight: .semibold))

                        Image(systemName: "heart.fill")
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
                    .shadow(color: dustyRose.opacity(0.4), radius: 12, x: 0, y: 6)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 28)
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
                                    .white.opacity(0.4),
                                    .clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: shimmerOffset)
                        .mask(RoundedRectangle(cornerRadius: 28))

                    // Border
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(
                            LinearGradient(
                                colors: [champagneGold.opacity(0.3), champagneGold.opacity(0.1)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                }
            )
            .padding(.horizontal, 28)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            // Celebration entrance haptic
            HapticManager.shared.celebrationEntrance()

            // Entrance animation
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                scale = 1.0
                opacity = 1.0
            }

            // Ring rotation
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                ringRotation = 360
            }

            // Heart pulse animation
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                heartScale = 1.15
            }

            // Shimmer effect
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false).delay(0.5)) {
                shimmerOffset = 400
            }

            // Show confetti after card appears with haptic burst
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                showConfetti = true
                HapticManager.shared.confettiBurst()
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

// MARK: - Wedding Confetti

struct WeddingConfettiView: View {
    @State private var confettiPieces: [WeddingConfettiPiece] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confettiPieces) { piece in
                    WeddingConfettiPieceView(piece: piece, screenHeight: geometry.size.height)
                }
            }
            .onAppear {
                generateConfetti(in: geometry.size)
            }
        }
        .ignoresSafeArea()
    }

    private func generateConfetti(in size: CGSize) {
        // Wedding-themed colors
        let weddingColors: [Color] = [
            Color(red: 255/255, green: 228/255, blue: 235/255), // Blush pink
            Color(red: 212/255, green: 175/255, blue: 125/255), // Champagne gold
            Color(red: 244/255, green: 194/255, blue: 194/255), // Soft rose
            Color(red: 255/255, green: 245/255, blue: 238/255), // Cream
            Color(red: 192/255, green: 134/255, blue: 134/255), // Dusty rose
            Color(red: 255/255, green: 223/255, blue: 211/255), // Peach
        ]

        confettiPieces = (0..<60).map { index in
            WeddingConfettiPiece(
                x: CGFloat.random(in: 0...size.width),
                delay: Double.random(in: 0...0.8),
                color: weddingColors.randomElement()!,
                type: WeddingConfettiType.allCases.randomElement()!,
                size: CGFloat.random(in: 8...16),
                swayAmount: CGFloat.random(in: 20...50)
            )
        }
    }
}

enum WeddingConfettiType: CaseIterable {
    case heart
    case sparkle
    case petal
    case ring
}

struct WeddingConfettiPiece: Identifiable {
    let id = UUID()
    let x: CGFloat
    let delay: Double
    let color: Color
    let type: WeddingConfettiType
    let size: CGFloat
    let swayAmount: CGFloat
}

struct WeddingConfettiPieceView: View {
    let piece: WeddingConfettiPiece
    let screenHeight: CGFloat

    @State private var yOffset: CGFloat = -60
    @State private var xOffset: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1
    @State private var scale: CGFloat = 0

    var body: some View {
        Group {
            switch piece.type {
            case .heart:
                Image(systemName: "heart.fill")
                    .font(.system(size: piece.size))
                    .foregroundColor(piece.color)

            case .sparkle:
                Image(systemName: "sparkle")
                    .font(.system(size: piece.size * 0.9))
                    .foregroundColor(piece.color)

            case .petal:
                Ellipse()
                    .fill(piece.color)
                    .frame(width: piece.size * 0.6, height: piece.size)

            case .ring:
                Circle()
                    .stroke(piece.color, lineWidth: 2)
                    .frame(width: piece.size * 0.8, height: piece.size * 0.8)
            }
        }
        .scaleEffect(scale)
        .rotationEffect(.degrees(rotation))
        .position(x: piece.x + xOffset, y: yOffset)
        .opacity(opacity)
        .onAppear {
            // Pop in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6).delay(piece.delay)) {
                scale = 1.0
            }

            // Fall down with gentle sway
            withAnimation(.easeIn(duration: 3.0).delay(piece.delay)) {
                yOffset = screenHeight + 60
                rotation = Double.random(in: 180...540)
            }

            // Sway side to side
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true).delay(piece.delay)) {
                xOffset = piece.swayAmount * (Bool.random() ? 1 : -1)
            }

            // Fade out at the end
            withAnimation(.easeIn(duration: 0.6).delay(piece.delay + 2.4)) {
                opacity = 0
            }
        }
    }
}

#Preview {
    CelebrationPopup(
        milestone: StreakMilestone(days: 7, title: "One Week!", message: "You've checked in for 7 days in a row. Keep up the great work!"),
        onDismiss: {}
    )
}
