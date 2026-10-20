import SwiftUI

struct ChecklistGroupView: View {
    let category: String
    let items: [ChecklistDisplayItem]
    var isLocked: Bool = false
    var customTodos: [UserTodo] = []
    @Binding var expandedItemId: UUID?
    let onToggle: (ChecklistDisplayItem) -> Void
    let onExpand: (UUID) -> Void
    let onAffiliateTap: (String) -> Void
    var onAddCustom: (() -> Void)? = nil
    var onToggleCustom: ((UserTodo) -> Void)? = nil
    var onEditCustom: ((UserTodo) -> Void)? = nil

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if isLocked {
                    // Locked preview: show only the first few curated items, blurred
                    let displayItems = Array(items.prefix(3))
                    ForEach(displayItems) { item in
                        ChecklistItemView(
                            item: item,
                            isExpanded: false,
                            onToggle: {},
                            onExpand: {},
                            onAffiliateTap: onAffiliateTap
                        )

                        if item.id != displayItems.last?.id {
                            Divider()
                                .padding(.leading, 52)
                        }
                    }
                } else {
                    // Curated tips
                    ForEach(items) { item in
                        ChecklistItemView(
                            item: item,
                            isExpanded: expandedItemId == item.id,
                            onToggle: { onToggle(item) },
                            onExpand: { onExpand(item.id) },
                            onAffiliateTap: onAffiliateTap
                        )

                        Divider()
                            .padding(.leading, 52)
                    }

                    // User-created to-dos
                    ForEach(customTodos) { todo in
                        CustomTodoItemView(
                            todo: todo,
                            onToggle: { onToggleCustom?(todo) },
                            onEdit: { onEditCustom?(todo) }
                        )

                        Divider()
                            .padding(.leading, 52)
                    }

                    // Add-your-own row
                    AddYourOwnRow {
                        onAddCustom?()
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

// MARK: - Custom To-Do Row

struct CustomTodoItemView: View {
    let todo: UserTodo
    let onToggle: () -> Void
    let onEdit: () -> Void

    @State private var checkmarkScale: CGFloat = 1.0

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Checkbox
            Button(action: {
                if !todo.isCompleted {
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
                            todo.isCompleted ? Color(hex: Constants.Colors.accent) : Color.gray.opacity(0.4),
                            lineWidth: 2
                        )
                        .frame(width: 28, height: 28)

                    if todo.isCompleted {
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

            // Content — tappable to edit
            Button(action: onEdit) {
                HStack(alignment: .top, spacing: 0) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(todo.title)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(
                                todo.isCompleted ?
                                Color(hex: Constants.Colors.secondaryText) :
                                Color(hex: Constants.Colors.buttonPrimary)
                            )
                            .strikethrough(todo.isCompleted, color: Color(hex: Constants.Colors.secondaryText))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)

                        if let note = todo.note, !note.isEmpty {
                            Text(note)
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Text("Added by you")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(hex: Constants.Colors.accent))
                    }

                    Spacer()

                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                        .padding(8)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}

// MARK: - Add Your Own Row

struct AddYourOwnRow: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.buttonTap()
            onTap()
        }) {
            HStack(spacing: 16) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: Constants.Colors.accent))
                    .frame(width: 28)

                Text("Add your own")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: Constants.Colors.accent))

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
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
