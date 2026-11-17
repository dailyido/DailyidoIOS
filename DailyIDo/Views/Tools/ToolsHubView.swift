import SwiftUI

/// The center tab: the couple's photo and the planning tools.
struct ToolsHubView: View {
    @StateObject private var subscriptionService = SubscriptionService.shared
    @ObservedObject private var authService = AuthService.shared
    @State private var couplePhoto: UIImage? = OnboardingViewModel.loadCouplePhoto()
    @State private var showTimeline = false
    @State private var showBudgetTracker = false

    private let accentColor = Color(hex: Constants.Colors.accent)

    private enum Tool: String {
        case timeline = "timeline_builder"
        case budget = "budget_tracker"
    }

    private var coupleNames: String {
        let names = [authService.currentUser?.name, authService.currentUser?.partnerName]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return names.isEmpty ? "Your wedding" : names.joined(separator: " & ")
    }

    private var countdown: String? {
        guard let user = authService.currentUser, !user.doesntKnowDate, let days = user.daysUntilWedding, days >= 0 else {
            return nil
        }
        switch days {
        case 0: return "It's your wedding day!"
        case 1: return "1 day to go"
        default: return "\(days) days to go"
        }
    }

    var body: some View {
        ZStack {
            Color(hex: Constants.Colors.background)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    header

                    VStack(alignment: .leading, spacing: 14) {
                        Text("PLANNING TOOLS")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                            .tracking(0.5)

                        ToolCard(
                            icon: "clock.badge.checkmark",
                            title: "Timeline Builder",
                            subtitle: "Answer a few questions and get your whole wedding day, minute by minute.",
                            badge: "NEW",
                            isLocked: !subscriptionService.isSubscribed
                        ) {
                            open(.timeline)
                        }

                        ToolCard(
                            icon: "dollarsign.circle",
                            title: "Budget Tracker",
                            subtitle: "Track every vendor, deposit and payment in one place.",
                            isLocked: !subscriptionService.isSubscribed
                        ) {
                            open(.budget)
                        }
                    }

                    Text("More tools are on the way!")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: Constants.Colors.secondaryText).opacity(0.7))
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 100)
            }
        }
        .onAppear {
            couplePhoto = OnboardingViewModel.loadCouplePhoto()
        }
        .fullScreenCover(isPresented: $showTimeline) {
            TimelineBuilderView()
        }
        .sheet(isPresented: $showBudgetTracker) {
            if let url = URL(string: Constants.WebLinks.budgetTracker) {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
    }

    private var header: some View {
        HStack(spacing: 16) {
            Group {
                if let photo = couplePhoto {
                    Image(uiImage: photo)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Circle()
                        .fill(accentColor.opacity(0.15))
                        .overlay(
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 26))
                                .foregroundColor(accentColor)
                        )
                }
            }
            .frame(width: 76, height: 76)
            .clipShape(Circle())
            .overlay(Circle().stroke(accentColor, lineWidth: 2))

            VStack(alignment: .leading, spacing: 4) {
                Text(coupleNames)
                    .font(.custom("CormorantGaramond-Bold", size: 30))
                    .foregroundColor(Color(hex: Constants.Colors.buttonPrimary))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)

                if let countdown {
                    Text(countdown)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                }
            }

            Spacer(minLength: 0)
        }
    }

    /// Both tools are Pro. Free users see the paywall first.
    private func open(_ tool: Tool) {
        AnalyticsService.shared.logToolOpened(tool.rawValue)
        if subscriptionService.isSubscribed {
            present(tool)
        } else {
            Task {
                await subscriptionService.showProBadgePaywall()
                if subscriptionService.isSubscribed {
                    present(tool)
                }
            }
        }
    }

    private func present(_ tool: Tool) {
        switch tool {
        case .timeline: showTimeline = true
        case .budget: showBudgetTracker = true
        }
    }
}

struct ToolCard: View {
    let icon: String
    let title: String
    let subtitle: String
    var badge: String? = nil
    var isLocked: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.buttonTap()
            action()
        }) {
            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(hex: Constants.Colors.accent).opacity(0.2))
                        .frame(width: 54, height: 54)
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(Color(hex: Constants.Colors.buttonPrimary))
                }

                VStack(alignment: .leading, spacing: 5) {
                    if let badge {
                        Text(badge)
                            .font(.system(size: 10, weight: .bold))
                            .tracking(0.5)
                            .foregroundColor(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color(hex: Constants.Colors.accent)))
                    }

                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: Constants.Colors.primaryText))

                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                Image(systemName: isLocked ? "crown.fill" : "chevron.right")
                    .font(.system(size: isLocked ? 15 : 14, weight: .semibold))
                    .foregroundColor(isLocked ? Color(hex: Constants.Colors.goldMid) : Color(hex: Constants.Colors.secondaryText).opacity(0.5))
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: Constants.Colors.cardBackground))
                    .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(hex: Constants.Colors.calendarBorder), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ToolsHubView()
}
