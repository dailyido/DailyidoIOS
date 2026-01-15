import SwiftUI

struct ChecklistGroupView: View {
    let category: String
    let items: [ChecklistDisplayItem]
    @Binding var expandedItemId: UUID?
    let onToggle: (ChecklistDisplayItem) -> Void
    let onExpand: (UUID) -> Void
    let onAffiliateTap: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ForEach(items) { item in
                ChecklistItemView(
                    item: item,
                    isExpanded: expandedItemId == item.id,
                    onToggle: { onToggle(item) },
                    onExpand: { onExpand(item.id) },
                    onAffiliateTap: onAffiliateTap
                )

                if item.id != items.last?.id {
                    Divider()
                        .padding(.leading, 52)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: Constants.Colors.cardBackground))
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
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
                isCompleted: false
            ),
            ChecklistDisplayItem(
                tip: Tip(
                    id: UUID(),
                    title: "Choose your venue",
                    tipText: "Research and visit potential venues that fit your vision and budget.",
                    hasIllustration: false,
                    illustrationUrl: nil,
                    monthCategory: "12+ months",
                    specificDay: nil,
                    priority: 2,
                    onChecklist: true,
                    affiliateUrl: nil,
                    affiliateButtonText: nil,
                    weddingType: nil,
                    isActive: true,
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
