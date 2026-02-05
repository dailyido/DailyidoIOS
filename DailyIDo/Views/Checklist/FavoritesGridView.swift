import SwiftUI

struct FavoritesGridView: View {
    let tips: [Tip]
    let onTipTapped: (Tip) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        if tips.isEmpty {
            // Empty state
            VStack(spacing: 12) {
                Image(systemName: "heart")
                    .font(.system(size: 36))
                    .foregroundColor(Color(hex: Constants.Colors.accent).opacity(0.5))

                Text("No favorites yet")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: Constants.Colors.primaryText))

                Text("Double-tap tips on the calendar\nto save them here!")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
        } else {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(tips) { tip in
                    FavoriteGridCell(tip: tip)
                        .onTapGesture {
                            HapticManager.shared.buttonTap()
                            onTipTapped(tip)
                        }
                }
            }
        }
    }
}

struct FavoriteGridCell: View {
    let tip: Tip

    var body: some View {
        VStack(spacing: 0) {
            // Illustration - taller vertical rectangle
            GeometryReader { geometry in
                ZStack {
                    Color(hex: Constants.Colors.accent).opacity(0.1)

                    if let urlString = RandomIllustrationService.shared.getIllustrationUrl(for: tip) {
                        CachedAsyncImage(url: URL(string: urlString)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geometry.size.width * 0.7)
                        } placeholder: {
                            ProgressView()
                                .tint(Color(hex: Constants.Colors.accent))
                        }
                    } else {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color(hex: Constants.Colors.accent).opacity(0.4))
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .frame(height: 140)

            // Title only
            Text(tip.title.replacingOccurrences(of: "\\n", with: " "))
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(hex: Constants.Colors.primaryText))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(Color(hex: Constants.Colors.cardBackground))
        }
        .background(Color(hex: Constants.Colors.cardBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    let sampleTips = [
        Tip(
            id: UUID(),
            title: "Start Your Guest List",
            tipText: "Begin compiling your guest list early.",
            hasIllustration: false,
            illustrationUrl: nil,
            category: "Planning",
            monthCategory: "12+ months",
            specificDay: nil,
            priority: 1,
            onChecklist: true,
            affiliateUrl: nil,
            affiliateButtonText: nil,
            weddingType: nil,
            isActive: true,
            funTip: false,
            createdAt: Date()
        ),
        Tip(
            id: UUID(),
            title: "Book Your Venue",
            tipText: "Research and book your wedding venue.",
            hasIllustration: false,
            illustrationUrl: nil,
            category: "Venue",
            monthCategory: "12+ months",
            specificDay: nil,
            priority: 1,
            onChecklist: true,
            affiliateUrl: nil,
            affiliateButtonText: nil,
            weddingType: nil,
            isActive: true,
            funTip: false,
            createdAt: Date()
        )
    ]

    return ScrollView {
        FavoritesGridView(tips: sampleTips) { tip in
            print("Tapped: \(tip.title)")
        }
        .padding()
    }
    .background(Color(hex: Constants.Colors.background))
}
