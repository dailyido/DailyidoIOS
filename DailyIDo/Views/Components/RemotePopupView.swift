import SwiftUI

struct RemotePopupView: View {
    let popup: RemotePopup
    let onDismiss: () -> Void
    let onCTATap: () -> Void

    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            // Popup content
            VStack(spacing: 20) {
                // Dismiss button
                HStack {
                    Spacer()
                    Button(action: dismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                            .padding(8)
                            .background(Circle().fill(Color.gray.opacity(0.1)))
                    }
                }

                // Image (if available)
                if let imageUrl = popup.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .cornerRadius(12)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 150)
                            .overlay(LoadingSpinner())
                    }
                }

                // Title
                Text(popup.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(hex: Constants.Colors.primaryText))
                    .multilineTextAlignment(.center)

                // Message
                Text(popup.message)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)

                // CTA Button (if available)
                if let ctaText = popup.ctaText, !ctaText.isEmpty {
                    PrimaryButton(title: ctaText) {
                        onCTATap()
                        dismiss()
                    }
                    .padding(.top, 8)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(hex: Constants.Colors.cardBackground))
            )
            .padding(.horizontal, 24)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.2)) {
            scale = 0.8
            opacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onDismiss()
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
            title: "Happy New Year!",
            message: "Wishing you and your partner a wonderful year of wedding planning ahead!",
            imageUrl: nil,
            ctaText: "Celebrate",
            ctaAction: nil,
            isActive: true
        ),
        onDismiss: {},
        onCTATap: {}
    )
}
