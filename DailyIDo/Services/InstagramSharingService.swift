import SwiftUI
import UIKit

class InstagramSharingService {
    static let shared = InstagramSharingService()

    private init() {}

    /// Check if Instagram is installed
    var canShareToInstagram: Bool {
        guard let url = URL(string: "instagram-stories://share") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }

    /// Check if Facebook is installed
    var canShareToFacebook: Bool {
        guard let url = URL(string: "facebook-stories://share") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }

    /// Share an image to Facebook Stories
    func shareToFacebookStories(image: UIImage, completion: ((Bool) -> Void)? = nil) {
        guard canShareToFacebook else {
            completion?(false)
            return
        }

        guard let imageData = image.pngData() else {
            completion?(false)
            return
        }

        let pasteboardItems: [String: Any] = [
            "com.facebook.sharedSticker.backgroundImage": imageData
        ]

        let pasteboardOptions: [UIPasteboard.OptionsKey: Any] = [
            .expirationDate: Date().addingTimeInterval(60 * 5)
        ]

        UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)

        guard let url = URL(string: "facebook-stories://share?source_application=com.dailyido.app") else {
            completion?(false)
            return
        }

        UIApplication.shared.open(url, options: [:]) { success in
            completion?(success)
        }
    }

    /// Share an image to Instagram Stories
    func shareToInstagramStories(image: UIImage, completion: ((Bool) -> Void)? = nil) {
        guard canShareToInstagram else {
            completion?(false)
            return
        }

        guard let imageData = image.pngData() else {
            completion?(false)
            return
        }

        let pasteboardItems: [String: Any] = [
            "com.instagram.sharedSticker.backgroundImage": imageData
        ]

        let pasteboardOptions: [UIPasteboard.OptionsKey: Any] = [
            .expirationDate: Date().addingTimeInterval(60 * 5)
        ]

        UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)

        guard let url = URL(string: "instagram-stories://share?source_application=com.dailyido.app") else {
            completion?(false)
            return
        }

        UIApplication.shared.open(url, options: [:]) { success in
            completion?(success)
        }
    }

    /// Render a SwiftUI view to an image
    @MainActor
    func renderViewToImage<V: View>(_ view: V, size: CGSize) -> UIImage? {
        // Create hosting controller with view sized to fill the entire frame
        let hostingController = UIHostingController(
            rootView: view
                .frame(width: size.width, height: size.height)
                .clipped()
        )

        // Configure the view to match exact size
        hostingController.view.frame = CGRect(origin: .zero, size: size)
        hostingController.view.backgroundColor = .white

        // Disable safe area insets (iOS 16.4+)
        if #available(iOS 16.4, *) {
            hostingController.safeAreaRegions = []
            hostingController.sizingOptions = .preferredContentSize
        }

        // Force layout pass
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()

        // Create renderer with scale 1.0 (1 point = 1 pixel for exact 1080x1920)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        format.opaque = true

        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            hostingController.view.drawHierarchy(
                in: CGRect(origin: .zero, size: size),
                afterScreenUpdates: true
            )
        }
    }
}

// MARK: - Shareable Calendar Card View (Instagram Story Size: 1080x1920)

struct ShareableCalendarCard: View {
    let daysUntilWedding: Int
    let tipTitle: String
    let tipText: String

    private let accentColor = Color(hex: Constants.Colors.accent)
    private let primaryColor = Color(hex: Constants.Colors.buttonPrimary)
    private let backgroundColor = Color(hex: "#FDF8F5")

    var body: some View {
        ZStack {
            // Beautiful gradient background - fills entire space
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#FDF2F8"),
                    Color(hex: "#FFF1F2"),
                    Color(hex: "#FFFBEB"),
                    Color(hex: "#FDF8F5")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Decorative elements
            VStack {
                HStack {
                    Circle()
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 300, height: 300)
                        .blur(radius: 80)
                        .offset(x: -100, y: -50)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    Circle()
                        .fill(accentColor.opacity(0.1))
                        .frame(width: 250, height: 250)
                        .blur(radius: 60)
                        .offset(x: 80, y: 50)
                }
            }

            // Main content
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 180)

                // Days countdown - HUGE
                VStack(spacing: 16) {
                    Text("\(daysUntilWedding)")
                        .font(.system(size: 280, weight: .light))
                        .foregroundColor(primaryColor)
                        .tracking(-10)

                    Text("DAYS UNTIL")
                        .font(.system(size: 32, weight: .semibold))
                        .tracking(12)
                        .foregroundColor(primaryColor.opacity(0.6))

                    Text("YOUR WEDDING")
                        .font(.system(size: 32, weight: .semibold))
                        .tracking(12)
                        .foregroundColor(primaryColor.opacity(0.6))
                }

                Spacer()
                    .frame(height: 80)

                // Decorative divider
                HStack(spacing: 24) {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [accentColor.opacity(0), accentColor.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 200, height: 2)

                    Image(systemName: "heart.fill")
                        .font(.system(size: 28))
                        .foregroundColor(accentColor)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [accentColor.opacity(0.6), accentColor.opacity(0)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 200, height: 2)
                }

                Spacer()
                    .frame(height: 80)

                // Today's tip section
                VStack(spacing: 28) {
                    Text("TODAY'S TIP")
                        .font(.system(size: 28, weight: .semibold))
                        .tracking(10)
                        .foregroundColor(accentColor)

                    Text(tipTitle)
                        .font(.custom("CormorantGaramond-Bold", size: 80))
                        .foregroundColor(primaryColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 60)
                        .lineLimit(3)
                        .minimumScaleFactor(0.6)

                    Text(tipText)
                        .font(.system(size: 60, weight: .regular))
                        .foregroundColor(primaryColor.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .lineSpacing(12)
                        .padding(.horizontal, 60)
                        .lineLimit(6)
                        .minimumScaleFactor(0.6)
                }

                Spacer()

                // Branding footer - prominent
                VStack(spacing: 24) {
                    // Decorative line
                    Rectangle()
                        .fill(accentColor.opacity(0.3))
                        .frame(width: 400, height: 1)

                    HStack(spacing: 16) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 24))
                            .foregroundColor(accentColor)

                        Text("Daily I Do")
                            .font(.custom("CormorantGaramond-Bold", size: 52))
                            .foregroundColor(primaryColor)

                        Image(systemName: "heart.fill")
                            .font(.system(size: 24))
                            .foregroundColor(accentColor)
                    }

                    Text("Your daily wedding planning companion")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(primaryColor.opacity(0.5))
                        .tracking(2)
                }
                .padding(.bottom, 120)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ShareableCalendarCard(
        daysUntilWedding: 247,
        tipTitle: "Start Your Guest List",
        tipText: "Begin compiling your guest list early. This will help you determine your venue size and budget."
    )
    .scaleEffect(0.3)
    .frame(width: 324, height: 576)
}
