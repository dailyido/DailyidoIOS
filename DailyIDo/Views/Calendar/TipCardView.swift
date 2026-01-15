import SwiftUI

struct TipCardView: View {
    let tip: Tip?
    let dayOffset: Int
    let daysUntilWedding: Int
    let date: Date
    var onShareTap: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            // Date header
            VStack(spacing: 4) {
                Text(date.formattedDayOfWeek.uppercased())
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: Constants.Colors.accent))
                    .tracking(1.5)

                Text(date.formattedMonthDay)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: Constants.Colors.primaryText))

                Text("\(daysUntilWedding) days until your wedding")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                    .padding(.top, 2)
            }
            .padding(.top, 24)
            .padding(.bottom, 20)

            Divider()
                .padding(.horizontal, 24)

            ScrollView {
                VStack(spacing: 20) {
                    // Illustration
                    if let tip = tip, tip.hasIllustration, let urlString = tip.fullIllustrationUrl {
                        AsyncImage(url: URL(string: urlString)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 180)
                            case .failure:
                                IllustrationPlaceholder()
                            case .empty:
                                ProgressView()
                                    .frame(height: 150)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .padding(.top, 20)
                    }

                    // Tip title
                    if let tip = tip {
                        Text(tip.title)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(hex: Constants.Colors.primaryText))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.top, tip.hasIllustration ? 0 : 20)
                    }

                    // Tip text
                    if let tip = tip {
                        Text(tip.tipText)
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 24)
                    }

                    // Affiliate button (if available)
                    if let tip = tip, let affiliateUrl = tip.affiliateUrl, !affiliateUrl.isEmpty {
                        Button(action: {
                            if let url = URL(string: affiliateUrl) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Text(tip.affiliateButtonText ?? "Shop Now")
                                    .font(.system(size: 15, weight: .medium))
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 13))
                            }
                            .foregroundColor(Color(hex: Constants.Colors.accent))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: Constants.Colors.accent), lineWidth: 1.5)
                            )
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.bottom, 20)
            }

            Spacer()

            // Share button
            if tip != nil {
                Button(action: {
                    HapticManager.shared.buttonTap()
                    onShareTap?()
                }) {
                    HStack(spacing: 8) {
                        Image("instagram")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color(hex: Constants.Colors.primaryText))

                        Text("Share to Instagram")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color(hex: Constants.Colors.primaryText))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                    )
                }
                .padding(.bottom, 24)
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(hex: Constants.Colors.cardBackground))
                .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 8)
        )
        .padding(.horizontal, 20)
    }
}

struct IllustrationPlaceholder: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: Constants.Colors.accent).opacity(0.1))
                .frame(height: 150)

            Image(systemName: "photo")
                .font(.system(size: 40))
                .foregroundColor(Color(hex: Constants.Colors.accent).opacity(0.5))
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    TipCardView(
        tip: Tip(
            id: UUID(),
            title: "Start Your Guest List",
            tipText: "Begin compiling your guest list early. This will help you determine your venue size and budget. Start with immediate family and close friends, then expand from there.",
            hasIllustration: false,
            illustrationUrl: nil,
            monthCategory: "12+ months",
            specificDay: nil,
            priority: 1,
            onChecklist: true,
            affiliateUrl: nil,
            affiliateButtonText: nil,
            weddingType: nil,
            isActive: true,
            createdAt: Date()
        ),
        dayOffset: 0,
        daysUntilWedding: 180,
        date: Date()
    )
}
