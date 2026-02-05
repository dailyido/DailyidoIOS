import SwiftUI

struct HeartFavoriteAnimation: View {
    @Binding var isShowing: Bool
    var onComplete: (() -> Void)?

    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 1.0

    var body: some View {
        if isShowing {
            ZStack {
                // Semi-transparent overlay
                Color.black.opacity(0.1)
                    .ignoresSafeArea()

                // Heart icon
                Image(systemName: "heart.fill")
                    .font(.system(size: 100, weight: .medium))
                    .foregroundColor(Color(hex: Constants.Colors.accent))
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .shadow(color: Color(hex: Constants.Colors.accent).opacity(0.5), radius: 20, x: 0, y: 10)
            }
            .onAppear {
                // Animate in
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    scale = 1.2
                }

                // Scale down slightly
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeOut(duration: 0.2)) {
                        scale = 1.0
                    }
                }

                // Fade out
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        opacity = 0
                        scale = 1.3
                    }
                }

                // Complete
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    isShowing = false
                    scale = 0.3
                    opacity = 1.0
                    onComplete?()
                }
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var isShowing = true

        var body: some View {
            ZStack {
                Color(hex: Constants.Colors.background)
                    .ignoresSafeArea()

                Button("Show Heart") {
                    isShowing = true
                }

                HeartFavoriteAnimation(isShowing: $isShowing)
            }
        }
    }

    return PreviewWrapper()
}
