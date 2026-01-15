import SwiftUI

struct CelebrationPopup: View {
    let milestone: StreakMilestone
    let onDismiss: () -> Void

    @State private var showConfetti = false
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            // Confetti
            if showConfetti {
                ConfettiView()
            }

            // Popup content
            VStack(spacing: 24) {
                // Celebration icon
                ZStack {
                    Circle()
                        .fill(Color(hex: Constants.Colors.accent).opacity(0.2))
                        .frame(width: 100, height: 100)

                    Image(systemName: "flame.fill")
                        .font(.system(size: 44))
                        .foregroundColor(Color(hex: Constants.Colors.accent))
                }

                // Streak count
                Text("\(milestone.days)")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundColor(Color(hex: Constants.Colors.accent))

                // Title
                Text(milestone.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(hex: Constants.Colors.primaryText))

                // Message
                Text(milestone.message)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                // Dismiss button
                PrimaryButton(title: "Keep Going!") {
                    dismiss()
                }
                .padding(.top, 8)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(hex: Constants.Colors.cardBackground))
            )
            .padding(.horizontal, 24)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showConfetti = true
            }
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.2)) {
            scale = 0.5
            opacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onDismiss()
        }
    }
}

struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confettiPieces) { piece in
                    ConfettiPieceView(piece: piece, screenHeight: geometry.size.height)
                }
            }
            .onAppear {
                generateConfetti(in: geometry.size)
            }
        }
        .ignoresSafeArea()
    }

    private func generateConfetti(in size: CGSize) {
        confettiPieces = (0..<50).map { _ in
            ConfettiPiece(
                x: CGFloat.random(in: 0...size.width),
                delay: Double.random(in: 0...0.5),
                color: [Color.red, Color.blue, Color.green, Color.yellow, Color.purple, Color.orange].randomElement()!
            )
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id = UUID()
    let x: CGFloat
    let delay: Double
    let color: Color
}

struct ConfettiPieceView: View {
    let piece: ConfettiPiece
    let screenHeight: CGFloat

    @State private var yOffset: CGFloat = -50
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1

    var body: some View {
        Rectangle()
            .fill(piece.color)
            .frame(width: 10, height: 10)
            .rotationEffect(.degrees(rotation))
            .position(x: piece.x, y: yOffset)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    Animation.easeIn(duration: 2.5)
                        .delay(piece.delay)
                ) {
                    yOffset = screenHeight + 50
                    rotation = Double.random(in: 360...720)
                }

                withAnimation(
                    Animation.easeIn(duration: 0.5)
                        .delay(piece.delay + 2.0)
                ) {
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
