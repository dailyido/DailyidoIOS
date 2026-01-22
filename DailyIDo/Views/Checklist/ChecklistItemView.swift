import SwiftUI

struct ChecklistItemView: View {
    let item: ChecklistDisplayItem
    let isExpanded: Bool
    let onToggle: () -> Void
    let onExpand: () -> Void
    let onAffiliateTap: (String) -> Void

    @State private var checkmarkScale: CGFloat = 1.0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main row
            HStack(alignment: .top, spacing: 16) {
                // Checkbox
                Button(action: {
                    if !item.isCompleted {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            checkmarkScale = 1.3
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                checkmarkScale = 1.0
                            }
                        }
                    }
                    onToggle()
                }) {
                    ZStack {
                        Circle()
                            .stroke(
                                item.isCompleted ? Color(hex: Constants.Colors.accent) : Color.gray.opacity(0.4),
                                lineWidth: 2
                            )
                            .frame(width: 28, height: 28)

                        if item.isCompleted {
                            Circle()
                                .fill(Color(hex: Constants.Colors.accent))
                                .frame(width: 28, height: 28)

                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .scaleEffect(checkmarkScale)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 2)

                // Content - tappable to expand
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.tip.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(
                            item.isCompleted ?
                            Color(hex: Constants.Colors.secondaryText) :
                            Color(hex: Constants.Colors.primaryText)
                        )
                        .strikethrough(item.isCompleted, color: Color(hex: Constants.Colors.secondaryText))

                    if item.isCompleted, let completedAt = item.completedAt {
                        Text("Completed \(completedAt.formattedShort)")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: Constants.Colors.secondaryText).opacity(0.7))
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    onExpand()
                }

                Spacer()

                // Expand button
                Button(action: onExpand) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                        .padding(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)

            // Expanded content
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    // Full tip text (supports \n for line breaks)
                    Text(item.tip.tipText.replacingOccurrences(of: "\\n", with: "\n"))
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                        .lineSpacing(4)

                    // Affiliate button (only if URL exists)
                    if let affiliateUrl = item.tip.affiliateUrl, !affiliateUrl.isEmpty {
                        Button(action: {
                            HapticManager.shared.buttonTap()
                            onAffiliateTap(affiliateUrl)
                        }) {
                            HStack {
                                Text(item.tip.affiliateButtonText ?? "Shop Now")
                                    .font(.system(size: 15, weight: .medium))
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 13))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(hex: Constants.Colors.accent))
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.leading, 44)
                .padding(.bottom, 16)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isExpanded)
    }
}

#Preview {
    VStack {
        ChecklistItemView(
            item: ChecklistDisplayItem(
                tip: Tip(
                    id: UUID(),
                    title: "Book your photographer",
                    tipText: "Research photographers whose style matches your vision. Book early as the best ones get reserved quickly!",
                    hasIllustration: false,
                    illustrationUrl: nil,
                    category: "Vendor",
                    monthCategory: "12+ months",
                    specificDay: nil,
                    priority: 1,
                    onChecklist: true,
                    affiliateUrl: "https://example.com",
                    affiliateButtonText: "Find Photographers",
                    weddingType: nil,
                    isActive: true,
                    funTip: false,
                    createdAt: Date()
                ),
                isCompleted: false
            ),
            isExpanded: true,
            onToggle: {},
            onExpand: {},
            onAffiliateTap: { _ in }
        )
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 4)
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
