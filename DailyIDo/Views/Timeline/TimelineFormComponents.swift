import SwiftUI

// Building blocks for the Timeline Builder questionnaire. Every optional
// question has a "Not sure" chip: choosing it clears the answer (nil), and the
// engine falls back to the default named next to it.

enum TimelineStyle {
    static let ink = Color(hex: Constants.Colors.buttonPrimary)
    static let text = Color(hex: Constants.Colors.primaryText)
    static let secondary = Color(hex: Constants.Colors.secondaryText)
    static let accent = Color(hex: Constants.Colors.accent)
    static let border = Color(hex: Constants.Colors.calendarBorder)
    static let card = Color(hex: Constants.Colors.cardBackground)
    static let cream = Color(hex: Constants.Colors.calendarCard)
    static let rose = Color(hex: "#A3545D")

    static func title(_ size: CGFloat) -> Font { .custom("CormorantGaramond-Bold", size: size) }
}

// MARK: - Question container

struct QuestionBlock<Content: View>: View {
    let number: String
    let title: String
    var isRequired = false
    var hint: String?
    /// Shown under a "Not sure" chip. Nil hides the chip (required questions).
    var notSureDefault: String?
    var isAnswered = true
    var onNotSure: (() -> Void)?
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(number)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(TimelineStyle.rose)
                    if isRequired {
                        Text("REQUIRED")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(0.5)
                            .foregroundColor(TimelineStyle.rose)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(TimelineStyle.accent.opacity(0.25)))
                    }
                }
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(TimelineStyle.text)
                    .fixedSize(horizontal: false, vertical: true)
                if let hint {
                    Text(hint)
                        .font(.system(size: 14))
                        .foregroundColor(TimelineStyle.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            content

            if let notSureDefault, let onNotSure {
                HStack(alignment: .center, spacing: 10) {
                    ChoiceChip(title: "Not sure", isSelected: !isAnswered, style: .subtle) {
                        onNotSure()
                    }
                    Text("We'll use: \(notSureDefault)")
                        .font(.system(size: 13))
                        .foregroundColor(TimelineStyle.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(TimelineStyle.card)
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 3)
        )
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(TimelineStyle.border, lineWidth: 1))
    }
}

// MARK: - Chips

struct ChoiceChip: View {
    enum Style { case standard, subtle }

    let title: String
    let isSelected: Bool
    var style: Style = .standard
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.buttonTap()
            action()
        }) {
            Text(title)
                .font(.system(size: style == .subtle ? 13 : 15, weight: .medium))
                .foregroundColor(isSelected ? .white : TimelineStyle.ink)
                .padding(.horizontal, style == .subtle ? 12 : 14)
                .padding(.vertical, style == .subtle ? 7 : 10)
                .background(
                    Capsule().fill(isSelected ? (style == .subtle ? TimelineStyle.secondary : TimelineStyle.ink) : Color.clear)
                )
                .overlay(
                    Capsule().stroke(isSelected ? Color.clear : TimelineStyle.ink.opacity(style == .subtle ? 0.3 : 0.5), lineWidth: 1.2)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Pick one.
struct ChoiceChips<Value: Hashable>: View {
    let options: [(Value, String)]
    @Binding var selection: Value?

    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(options.indices, id: \.self) { index in
                let option = options[index]
                ChoiceChip(title: option.1, isSelected: selection == option.0) {
                    selection = option.0
                }
            }
        }
    }
}

/// Pick any number. Touching any chip makes the answer explicit (an empty set
/// means "none"); "Not sure" sets it back to nil.
struct MultiChoiceChips<Value: Hashable>: View {
    let options: [(Value, String)]
    @Binding var selection: Set<Value>?
    /// What to start from the first time a chip is tapped (the default set).
    var startingSet: Set<Value> = []

    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(options.indices, id: \.self) { index in
                let option = options[index]
                ChoiceChip(title: option.1, isSelected: (selection ?? []).contains(option.0)) {
                    var current = selection ?? startingSet
                    if current.contains(option.0) {
                        current.remove(option.0)
                    } else {
                        current.insert(option.0)
                    }
                    selection = current
                }
            }
        }
    }
}

struct YesNoChips: View {
    @Binding var selection: Bool?

    var body: some View {
        ChoiceChips(options: [(true, "Yes"), (false, "No")], selection: $selection)
    }
}

// MARK: - Fields

/// A time answer. Nil shows a "Choose a time" button that starts at `suggested`.
struct TimeAnswerField: View {
    @Binding var time: TimeOfDay?
    var suggested: TimeOfDay
    var prompt = "Choose a time"

    var body: some View {
        if let current = time {
            HStack {
                DatePicker(
                    "",
                    selection: Binding(
                        get: { current.date() },
                        set: { time = TimeOfDay(date: $0) }
                    ),
                    displayedComponents: .hourAndMinute
                )
                .labelsHidden()
                .tint(TimelineStyle.ink)
                Spacer()
            }
        } else {
            Button(action: {
                HapticManager.shared.buttonTap()
                time = suggested
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                    Text(prompt)
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(TimelineStyle.ink)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .overlay(Capsule().stroke(TimelineStyle.ink.opacity(0.5), lineWidth: 1.2))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

/// A calendar date stored as "yyyy-MM-dd".
struct DateAnswerField: View {
    @Binding var date: String?
    var suggested: Date = Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
    var prompt = "Choose a date"

    var body: some View {
        if let current = date, let local = TimelineDate.localDate(from: current) {
            HStack {
                DatePicker(
                    "",
                    selection: Binding(
                        get: { local },
                        set: { date = TimelineDate.string(fromLocal: $0) }
                    ),
                    displayedComponents: .date
                )
                .labelsHidden()
                .tint(TimelineStyle.ink)
                Spacer()
            }
        } else {
            Button(action: {
                HapticManager.shared.buttonTap()
                date = TimelineDate.string(fromLocal: suggested)
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                    Text(prompt)
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(TimelineStyle.ink)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .overlay(Capsule().stroke(TimelineStyle.ink.opacity(0.5), lineWidth: 1.2))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

/// A − value + stepper. Nil shows "Not sure" and steps from `defaultValue`.
struct NumberAnswerField: View {
    @Binding var value: Double?
    var range: ClosedRange<Double>
    var step: Double = 1
    var defaultValue: Double
    var label: (Double) -> String

    var body: some View {
        HStack(spacing: 14) {
            stepButton("minus") { change(by: -step) }
                .disabled((value ?? defaultValue) <= range.lowerBound && value != nil)

            Text(value.map(label) ?? "Not sure")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(value == nil ? TimelineStyle.secondary : TimelineStyle.text)
                .frame(minWidth: 110)
                .monospacedDigit()

            stepButton("plus") { change(by: step) }
                .disabled((value ?? defaultValue) >= range.upperBound && value != nil)

            Spacer(minLength: 0)
        }
    }

    private func change(by delta: Double) {
        guard let current = value else {
            value = defaultValue
            return
        }
        value = min(max(current + delta, range.lowerBound), range.upperBound)
    }

    private func stepButton(_ icon: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            HapticManager.shared.buttonTap()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(TimelineStyle.ink)
                .frame(width: 40, height: 40)
                .overlay(Circle().stroke(TimelineStyle.ink.opacity(0.4), lineWidth: 1.2))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AnswerTextField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .font(.system(size: 16))
            .foregroundColor(TimelineStyle.text)
            .padding(.horizontal, 14)
            .frame(height: 48)
            .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1.2))
    }
}

struct SubLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(TimelineStyle.secondary)
    }
}

// MARK: - Bindings

extension Binding where Value == String? {
    /// "" ↔ nil, for text fields over optional answers.
    var orEmpty: Binding<String> {
        Binding<String>(
            get: { wrappedValue ?? "" },
            set: { wrappedValue = $0.isEmpty ? nil : $0 }
        )
    }
}

extension Binding where Value == Int? {
    var asDouble: Binding<Double?> {
        Binding<Double?>(
            get: { wrappedValue.map(Double.init) },
            set: { wrappedValue = $0.map { Int($0) } }
        )
    }
}

// MARK: - Flow layout

/// Wraps chips onto as many lines as they need.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrange(subviews: subviews, width: proposal.width ?? .infinity)
        let height = rows.map(\.height).reduce(0, +) + spacing * CGFloat(max(rows.count - 1, 0))
        let width = rows.map(\.width).max() ?? 0
        return CGSize(width: proposal.width ?? width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in arrange(subviews: subviews, width: bounds.width) {
            var x = bounds.minX
            for index in row.indices {
                let size = fittedSize(subviews[index], width: bounds.width)
                subviews[index].place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += row.height + spacing
        }
    }

    private struct Row {
        var indices: [Int] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    /// A chip's natural size, wrapped onto more lines if it's wider than the row.
    private func fittedSize(_ subview: LayoutSubview, width: CGFloat) -> CGSize {
        let natural = subview.sizeThatFits(.unspecified)
        guard width.isFinite, natural.width > width else { return natural }
        return subview.sizeThatFits(ProposedViewSize(width: width, height: nil))
    }

    private func arrange(subviews: Subviews, width: CGFloat) -> [Row] {
        var rows: [Row] = [Row()]
        for index in subviews.indices {
            let size = fittedSize(subviews[index], width: width)
            let extra = rows[rows.count - 1].indices.isEmpty ? size.width : size.width + spacing
            if rows[rows.count - 1].width + extra > width, !rows[rows.count - 1].indices.isEmpty {
                rows.append(Row())
            }
            let addition = rows[rows.count - 1].indices.isEmpty ? size.width : size.width + spacing
            rows[rows.count - 1].indices.append(index)
            rows[rows.count - 1].width += addition
            rows[rows.count - 1].height = max(rows[rows.count - 1].height, size.height)
        }
        return rows
    }
}
