import SwiftUI

struct LoadingSpinner: View {
    @State private var isAnimating = false

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(Color(hex: Constants.Colors.accent), lineWidth: 3)
            .frame(width: 40, height: 40)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .animation(
                Animation.linear(duration: 1)
                    .repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

struct LoadingOverlay: View {
    let messages: [String]
    @State private var currentMessageIndex = 0

    var body: some View {
        ZStack {
            Color(hex: Constants.Colors.background)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                LoadingSpinner()
                    .scaleEffect(1.5)

                Text(messages[currentMessageIndex])
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: Constants.Colors.primaryText))
                    .multilineTextAlignment(.center)
                    .animation(.easeInOut(duration: 0.3), value: currentMessageIndex)
            }
        }
        .onAppear {
            startMessageRotation()
        }
    }

    private func startMessageRotation() {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            withAnimation {
                currentMessageIndex = (currentMessageIndex + 1) % messages.count
            }
        }
    }
}

struct FullScreenLoading: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                LoadingSpinner()

                Text("Loading...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: Constants.Colors.primaryText).opacity(0.9))
            )
        }
    }
}

#Preview {
    VStack {
        LoadingSpinner()

        LoadingOverlay(messages: [
            "Creating custom countdown...",
            "Looking up the sunset on your wedding day...",
            "Creating tip calendar...",
            "Organizing wedding checklist..."
        ])
    }
}
