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
    var illustrationImage: UIImage? = nil

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
                    .frame(height: 120)

                // Days countdown
                VStack(spacing: 12) {
                    Text("\(daysUntilWedding)")
                        .font(.system(size: illustrationImage != nil ? 200 : 280, weight: .light))
                        .foregroundColor(primaryColor)
                        .tracking(-8)

                    Text("DAYS UNTIL YOUR WEDDING")
                        .font(.system(size: 28, weight: .semibold))
                        .tracking(8)
                        .foregroundColor(primaryColor.opacity(0.6))
                }

                Spacer()
                    .frame(height: 50)

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
                    .frame(height: 50)

                // Illustration (if available)
                if let uiImage = illustrationImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 280)
                        .padding(.horizontal, 120)

                    Spacer()
                        .frame(height: 30)
                }

                // Today's tip section
                VStack(spacing: illustrationImage != nil ? 20 : 32) {
                    Text("TODAY'S TIP")
                        .font(.system(size: illustrationImage != nil ? 28 : 34, weight: .semibold))
                        .tracking(8)
                        .foregroundColor(accentColor)

                    Text(tipTitle.replacingOccurrences(of: "\\n", with: "\n"))
                        .font(.custom("CormorantGaramond-Bold", size: illustrationImage != nil ? 72 : 100))
                        .foregroundColor(primaryColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 80)
                        .lineLimit(4)
                        .minimumScaleFactor(0.4)

                    Text(tipText.replacingOccurrences(of: "\\n", with: "\n"))
                        .font(.system(size: illustrationImage != nil ? 48 : 60, weight: .regular))
                        .foregroundColor(primaryColor.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .lineSpacing(illustrationImage != nil ? 8 : 14)
                        .padding(.horizontal, 80)
                        .lineLimit(illustrationImage != nil ? 6 : 8)
                        .minimumScaleFactor(0.35)
                }

                Spacer()

                // Branding footer - prominent
                VStack(spacing: 20) {
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
                .padding(.bottom, 100)
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
