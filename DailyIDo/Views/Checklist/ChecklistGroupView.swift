import SwiftUI

struct ChecklistGroupView: View {
    let category: String
    let items: [ChecklistDisplayItem]
    var isLocked: Bool = false
    @Binding var expandedItemId: UUID?
    let onToggle: (ChecklistDisplayItem) -> Void
    let onExpand: (UUID) -> Void
    let onAffiliateTap: (String) -> Void

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Show only first 2 items when locked (for preview)
                let displayItems = isLocked ? Array(items.prefix(3)) : items

                ForEach(displayItems) { item in
                    ChecklistItemView(
                        item: item,
                        isExpanded: isLocked ? false : (expandedItemId == item.id),
                        onToggle: { if !isLocked { onToggle(item) } },
                        onExpand: { if !isLocked { onExpand(item.id) } },
                        onAffiliateTap: onAffiliateTap
                    )

                    if item.id != displayItems.last?.id {
                        Divider()
                            .padding(.leading, 52)
                    }
                }
            }
            .blur(radius: isLocked ? 6 : 0)
            .allowsHitTesting(!isLocked)

            // Locked overlay
            if isLocked {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.7))

                VStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: Constants.Colors.accent))

                    Text("This will be unlocked\nas you get closer!")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color(hex: Constants.Colors.buttonPrimary))
                        .multilineTextAlignment(.center)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    ChecklistGroupView(
        category: "12+ months",
        items: [
            ChecklistDisplayItem(
                tip: Tip(
                    id: UUID(),
                    title: "Set your budget",
                    tipText: "Work with your partner and families to establish a realistic wedding budget.",
                    hasIllustration: false,
                    illustrationUrl: nil,
                    category: "Budget",
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
                isCompleted: false
            ),
            ChecklistDisplayItem(
                tip: Tip(
                    id: UUID(),
                    title: "Choose your venue",
                    tipText: "Research and visit potential venues that fit your vision and budget.",
                    hasIllustration: false,
                    illustrationUrl: nil,
                    category: "Venue",
                    monthCategory: "12+ months",
                    specificDay: nil,
                    priority: 2,
                    onChecklist: true,
                    affiliateUrl: nil,
                    affiliateButtonText: nil,
                    weddingType: nil,
                    isActive: true,
                    funTip: false,
                    createdAt: Date()
                ),
                isCompleted: true
            )
        ],
        expandedItemId: .constant(nil),
        onToggle: { _ in },
        onExpand: { _ in },
        onAffiliateTap: { _ in }
    )
    .padding()
}
