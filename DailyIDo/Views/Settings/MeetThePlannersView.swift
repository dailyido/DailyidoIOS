import SwiftUI
import SafariServices

// MARK: - Safari View for in-app web browsing
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        let safari = SFSafariViewController(url: url, configuration: config)
        safari.preferredControlTintColor = UIColor(Color(hex: Constants.Colors.accent))
        return safari
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

struct PlannerInfo: Identifiable {
    let id = UUID()
    let name: String
    let photo: String
    let signature: String
    let signatureHeight: CGFloat
    let bio: String
    let instagramHandle: String

    /// Deep link to open Instagram app directly
    var instagramAppURL: URL? {
        URL(string: "instagram://user?username=\(instagramHandle)")
    }

    /// Fallback web URL if app isn't installed
    var instagramWebURL: URL? {
        URL(string: "https://instagram.com/\(instagramHandle)")
    }
}

struct MeetThePlannersView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0

    private let accentColor = Color(hex: Constants.Colors.accent)
    private let primaryColor = Color(hex: Constants.Colors.buttonPrimary)
    private let secondaryText = Color(hex: Constants.Colors.secondaryText)

    private let planners: [PlannerInfo] = [
        PlannerInfo(
            name: "Heather",
            photo: "heather_about",
            signature: "heather_signature",
            signatureHeight: 40,
            bio: "Hi there! I'm so happy to meet you! I was born and raised on Cape Cod, where I now live with my husband, Matt, and our two boys, Wyatt and Levi. Being a mom of two busy boys means I'm calm under pressure, quick on my feet, and very comfortable handling a little chaos, all skills that translate extremely well to wedding days.\n\nWe love spending time outdoors, whether it's peaceful cranberry bog walks, snowmobiling through the mountains in Maine, or tending to our apple trees at home together. Being a wedding planner is truly the icing on the cake, and I feel so lucky to love what I do every single day.",
            instagramHandle: "HeatherRumulWeddings"
        ),
        PlannerInfo(
            name: "Jamie",
            photo: "jamie_new",
            signature: "jamie_signature",
            signatureHeight: 55,
            bio: "Hi! I'm so excited to meet you! I've been part of the Cape Cod wedding industry since 2006 and founded my wedding planning business, Cape Cod Celebrations, in 2007. Today, I continue to run the company alongside an incredible team of talented women who share a passion for creating meaningful, beautifully executed celebrations.\n\nBorn and raised on Cape Cod, I'm proud to call it home, where I live with my husband, Neill, and our son, Jack. When I am not planning or working weddings, we love traveling, playing pickleball, and spending time with friends and family.",
            instagramHandle: "CapeCodCelebrations"
        )
    ]

    private let totalPages = 3 // 2 planners + 1 "Our Story" page

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: Constants.Colors.background)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Swipeable pages
                    TabView(selection: $currentPage) {
                        ForEach(Array(planners.enumerated()), id: \.element.id) { index, planner in
                            PlannerPageView(
                                planner: planner,
                                onInstagramTap: {
                                    // Try to open Instagram app first, fall back to web
                                    if let appURL = planner.instagramAppURL,
                                       UIApplication.shared.canOpenURL(appURL) {
                                        UIApplication.shared.open(appURL)
                                    } else if let webURL = planner.instagramWebURL {
                                        UIApplication.shared.open(webURL)
                                    }
                                }
                            )
                            .tag(index)
                        }

                        // Third page: Our Story
                        OurStoryPageView()
                            .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.3), value: currentPage)

                    // Page indicator dots
                    HStack(spacing: 8) {
                        ForEach(0..<totalPages, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? accentColor : accentColor.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .animation(.easeInOut(duration: 0.2), value: currentPage)
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Meet the Planners")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(accentColor)
                }
            }
        }
    }
}

struct PlannerPageView: View {
    let planner: PlannerInfo
    let onInstagramTap: () -> Void

    private let accentColor = Color(hex: Constants.Colors.accent)
    private let primaryColor = Color(hex: Constants.Colors.buttonPrimary)
    private let secondaryText = Color(hex: Constants.Colors.secondaryText)

    // Calculate image size based on screen height
    private func imageSize(for screenHeight: CGFloat) -> CGFloat {
        // Reserve space for: nav bar (~50), name (~50), bio (~150), signature (~70), button (~60), padding (~100), page dots (~40)
        // Total reserved: ~520pt
        let reservedSpace: CGFloat = 520
        let availableForImage = screenHeight - reservedSpace
        return min(max(availableForImage, 100), 180) // Min 100, max 180
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Planner photo
                    Image(planner.photo)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: imageSize(for: geometry.size.height), height: imageSize(for: geometry.size.height))
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(accentColor.opacity(0.3), lineWidth: 3)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        .padding(.top, 16)

                    // Name
                    Text(planner.name)
                        .font(.custom("CormorantGaramond-Bold", size: 32))
                        .foregroundColor(primaryColor)
                        .padding(.top, 14)

                    // Bio
                    Text(planner.bio)
                        .font(.system(size: 15))
                        .foregroundColor(secondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 28)
                        .padding(.top, 10)
                        .fixedSize(horizontal: false, vertical: true)

                    // Signature
                    Image(planner.signature)
                        .resizable()
                        .scaledToFit()
                        .frame(height: planner.signatureHeight)
                        .padding(.top, 14)

                    // Instagram button
                    Button(action: {
                        HapticManager.shared.buttonTap()
                        onInstagramTap()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 14))

                            Text("Follow \(planner.name) on Instagram")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(accentColor)
                        )
                        .shadow(color: accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.top, 18)
                    .padding(.bottom, 16)
                }
                .frame(minHeight: geometry.size.height - 40) // Account for page dots
            }
        }
    }
}

// MARK: - Our Story Page (Third page)
struct OurStoryPageView: View {
    private let accentColor = Color(hex: Constants.Colors.accent)
    private let primaryColor = Color(hex: Constants.Colors.buttonPrimary)
    private let secondaryText = Color(hex: Constants.Colors.secondaryText)

    private let storyText = """
Jamie and Heather first connected in 2013 while working a wedding together on Cape Cod - Jamie as a planner and Heather as a Event Specialist. Over the next 5 years they bonded over their shared love of celebrations, thoughtful details, and the magic of wedding days. In 2019, Jamie invited Heather to join the Cape Cod Celebrations team, and the rest is history.

Together, they're excited to bring their passion for weddings, obsession with seamless timelines, calm demeanors, fun personalities, and endless creativity straight to your phone each day with thoughtfully curated tips inspired by their own planning journeys.
"""

    // Calculate image size based on screen height
    private func imageSize(for screenHeight: CGFloat) -> CGFloat {
        let reservedSpace: CGFloat = 480
        let availableForImage = screenHeight - reservedSpace
        return min(max(availableForImage, 100), 180)
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Photo of both planners
                    Image("heather_jamie")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: imageSize(for: geometry.size.height), height: imageSize(for: geometry.size.height))
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(accentColor.opacity(0.3), lineWidth: 3)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        .padding(.top, 16)

                    // Title
                    Text("Our Story")
                        .font(.custom("CormorantGaramond-Bold", size: 32))
                        .foregroundColor(primaryColor)
                        .padding(.top, 14)

                    // Story text
                    Text(storyText)
                        .font(.system(size: 15))
                        .foregroundColor(secondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 28)
                        .padding(.top, 10)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 40)
                }
                .frame(minHeight: geometry.size.height - 40)
            }
        }
    }
}

#Preview {
    MeetThePlannersView()
}
