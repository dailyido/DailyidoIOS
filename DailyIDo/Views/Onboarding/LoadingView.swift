import SwiftUI

struct LoadingView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var currentMessageIndex = 0
    @State private var timer: Timer?
    @State private var messageOpacity: Double = 1
    @State private var showInitial = false
    @State private var orbitRotation: Double = 0

    private let accentColor = Color(hex: Constants.Colors.accent)
    private let primaryColor = Color(hex: Constants.Colors.buttonPrimary)
    private let secondaryColor = Color(hex: Constants.Colors.secondaryText)

    var body: some View {
        ZStack {
            // Atmospheric background
            backgroundLayer

            VStack(spacing: 0) {
                Spacer()

                // Elegant orbital animation
                orbitalLoader
                    .padding(.bottom, 48)

                // Status badge
                statusBadge
                    .padding(.bottom, 24)
                    .opacity(showInitial ? 1 : 0)
                    .offset(y: showInitial ? 0 : 10)

                // Rotating message with elegant typography
                messageView
                    .padding(.horizontal, 48)

                Spacer()

                // Progress indicator dots
                progressDots
                    .padding(.bottom, 80)
                    .opacity(showInitial ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showInitial = true
            }
            startOrbitAnimation()
            startMessageRotation()
            Task {
                await viewModel.startLoadingProcess()
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    // MARK: - Background

    private var backgroundLayer: some View {
        ZStack {
            Color(hex: Constants.Colors.background)

            // Soft gradient orbs
            Circle()
                .fill(
                    RadialGradient(
                        colors: [accentColor.opacity(0.12), accentColor.opacity(0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 250
                    )
                )
                .frame(width: 500, height: 500)
                .offset(y: -100)
                .blur(radius: 80)

            // Bottom accent
            Circle()
                .fill(
                    RadialGradient(
                        colors: [accentColor.opacity(0.08), accentColor.opacity(0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(y: 350)
                .blur(radius: 60)
        }
        .ignoresSafeArea()
    }

    // MARK: - Orbital Loader

    private var orbitalLoader: some View {
        ZStack {
            // Outer orbit ring
            Circle()
                .stroke(accentColor.opacity(0.15), lineWidth: 1)
                .frame(width: 180, height: 180)

            // Middle orbit ring
            Circle()
                .stroke(accentColor.opacity(0.2), lineWidth: 1)
                .frame(width: 120, height: 120)

            // Inner glow ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [accentColor.opacity(0.4), accentColor.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 2
                )
                .frame(width: 70, height: 70)

            // Center heart with pulse
            ZStack {
                // Pulse effect
                Circle()
                    .fill(accentColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .scaleEffect(showInitial ? 1.3 : 1)
                    .opacity(showInitial ? 0 : 0.5)
                    .animation(
                        .easeInOut(duration: 1.2).repeatForever(autoreverses: false),
                        value: showInitial
                    )

                Circle()
                    .fill(accentColor.opacity(0.15))
                    .frame(width: 50, height: 50)

                Image(systemName: "heart.fill")
                    .font(.system(size: 24))
                    .foregroundColor(accentColor)
            }

            // Orbiting elements
            orbitingElements
                .rotationEffect(.degrees(orbitRotation))
        }
        .frame(width: 200, height: 200)
    }

    private var orbitingElements: some View {
        ZStack {
            // Outer orbit - sparkle
            Image(systemName: "sparkle")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(accentColor.opacity(0.7))
                .offset(y: -90)

            // Outer orbit - heart
            Image(systemName: "heart.fill")
                .font(.system(size: 8))
                .foregroundColor(accentColor.opacity(0.5))
                .offset(y: -90)
                .rotationEffect(.degrees(120))

            // Middle orbit - sparkle
            Image(systemName: "sparkle")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(accentColor.opacity(0.6))
                .offset(y: -60)
                .rotationEffect(.degrees(200))

            // Middle orbit - dot
            Circle()
                .fill(accentColor.opacity(0.5))
                .frame(width: 5, height: 5)
                .offset(y: -60)
                .rotationEffect(.degrees(320))
        }
    }

    // MARK: - Status Badge

    private var statusBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(accentColor)
                .frame(width: 6, height: 6)
                .opacity(showInitial ? 1 : 0.3)
                .animation(
                    .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                    value: showInitial
                )

            Text("CREATING YOUR PLAN")
                .font(.system(size: 11, weight: .semibold))
                .kerning(1.5)
                .foregroundColor(secondaryColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color(hex: Constants.Colors.background))
                .shadow(color: primaryColor.opacity(0.08), radius: 20, y: 4)
        )
        .overlay(
            Capsule()
                .stroke(accentColor.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Message View

    private var messageView: some View {
        VStack(spacing: 12) {
            Text(viewModel.loadingMessages[currentMessageIndex])
                .font(.custom("CormorantGaramond-SemiBold", size: 26))
                .foregroundColor(primaryColor)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .opacity(messageOpacity)
                .animation(.easeInOut(duration: 0.3), value: messageOpacity)

            // Decorative line
            HStack(spacing: 8) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [accentColor.opacity(0), accentColor.opacity(0.5)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 30, height: 1)

                Image(systemName: "sparkle")
                    .font(.system(size: 8))
                    .foregroundColor(accentColor.opacity(0.6))

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [accentColor.opacity(0.5), accentColor.opacity(0)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 30, height: 1)
            }
            .opacity(showInitial ? 1 : 0)
        }
        .frame(height: 100)
    }

    // MARK: - Progress Dots

    private var progressDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<viewModel.loadingMessages.count, id: \.self) { index in
                Circle()
                    .fill(index == currentMessageIndex ? accentColor : accentColor.opacity(0.3))
                    .frame(width: index == currentMessageIndex ? 8 : 6,
                           height: index == currentMessageIndex ? 8 : 6)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentMessageIndex)
            }
        }
    }

    // MARK: - Animations

    private func startOrbitAnimation() {
        withAnimation(
            .linear(duration: 20)
            .repeatForever(autoreverses: false)
        ) {
            orbitRotation = 360
        }
    }

    private func startMessageRotation() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
            // Fade out
            withAnimation(.easeOut(duration: 0.2)) {
                messageOpacity = 0
            }

            // Change message and fade in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                currentMessageIndex = (currentMessageIndex + 1) % viewModel.loadingMessages.count
                withAnimation(.easeIn(duration: 0.3)) {
                    messageOpacity = 1
                }
            }
        }
    }
}

#Preview {
    LoadingView(viewModel: OnboardingViewModel())
}
