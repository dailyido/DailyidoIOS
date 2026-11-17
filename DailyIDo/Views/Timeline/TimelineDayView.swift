import SwiftUI

/// The generated wedding-day timeline: warnings, the day by phase, the rest of
/// the weekend, and (when the couple is undecided) both versions side by side.
struct TimelineDayView: View {
    @ObservedObject var store: TimelineStore
    let onEditAnswers: () -> Void

    private enum Mode: Hashable {
        case branch(FirstLookBranch)
        case compare
    }

    @State private var mode: Mode?
    @State private var editingItem: TimelineItem?
    @State private var showReorder = false
    @State private var showHidden = false
    @State private var showBookACall = false
    @State private var confirmStartOver = false

    private var q: TimelineQuestionnaire { store.questionnaire }
    private var branches: [FirstLookBranch] { q.branches }

    private var resolvedMode: Mode {
        if let mode {
            switch mode {
            case .compare where branches.count > 1: return mode
            case .branch(let branch) where branches.contains(branch): return mode
            default: break
            }
        }
        return branches.count > 1 ? .compare : .branch(branches.first ?? .firstLook)
    }

    private var activeResult: TimelineResult? {
        if case .branch(let branch) = resolvedMode { return store.results[branch] }
        return nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header

                if branches.count > 1 {
                    modePicker
                }

                if resolvedMode == .compare,
                   let firstLook = store.results[.firstLook],
                   let noFirstLook = store.results[.noFirstLook] {
                    TimelineCompareView(firstLook: firstLook, noFirstLook: noFirstLook) { branch in
                        HapticManager.shared.success()
                        store.chooseBranch(branch)
                        mode = .branch(branch)
                    }
                } else if let result = activeResult {
                    if !result.warnings.isEmpty {
                        warnings(result.warnings)
                    }
                    rainPlan
                    dayTimeline(result)
                    hiddenItems(result)
                    weekend(result)
                }

                bookACallCard
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .background(Color(hex: Constants.Colors.background).ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        onEditAnswers()
                    } label: {
                        Label("Edit answers", systemImage: "pencil")
                    }
                    if let result = activeResult, !result.sequences.isEmpty {
                        Button {
                            showReorder = true
                        } label: {
                            Label("Reorder moments", systemImage: "arrow.up.arrow.down")
                        }
                    }
                    Button(role: .destructive) {
                        confirmStartOver = true
                    } label: {
                        Label("Start over", systemImage: "arrow.counterclockwise")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 18))
                        .foregroundColor(TimelineStyle.ink)
                }
            }
        }
        .sheet(item: $editingItem) { item in
            TimelineItemEditor(item: item, store: store) {
                onEditAnswers()
            }
        }
        .sheet(isPresented: $showReorder) {
            if let result = activeResult {
                ReorderMomentsView(store: store, sequences: result.sequences)
            }
        }
        .sheet(isPresented: $showBookACall) {
            if let url = URL(string: Constants.WebLinks.bookACall) {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
        .confirmationDialog("Start over?", isPresented: $confirmStartOver, titleVisibility: .visible) {
            Button("Clear my answers and edits", role: .destructive) {
                store.startOver()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This clears your questionnaire answers and timeline edits.")
        }
        .onAppear {
            if let result = activeResult, !result.warnings.isEmpty {
                AnalyticsService.shared.logTimelineWarningsShown(result.warnings.map(\.kind.rawValue))
            }
        }
    }

    // MARK: - Header

    private var coupleNames: String {
        q.partners.map(\.displayName).joined(separator: " & ")
    }

    private var dateLine: String? {
        guard let string = q.weddingDate, let date = TimelineDate.date(from: string) else { return nil }
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: date)
    }

    private var placeLine: String? {
        let parts = [q.ceremonyVenue, q.ceremonyCity]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(coupleNames)
                .font(TimelineStyle.title(32))
                .foregroundColor(TimelineStyle.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
            if let dateLine {
                Text(dateLine)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(TimelineStyle.text)
            }
            if let placeLine {
                Text(placeLine)
                    .font(.system(size: 14))
                    .foregroundColor(TimelineStyle.secondary)
            }
            FlowLayout(spacing: 8) {
                if let start = q.ceremonyStart {
                    InfoChip(icon: "heart.fill", text: "Ceremony \(start.formatted)")
                }
                if let sunset = store.sunset {
                    InfoChip(icon: "sun.horizon.fill", text: "Sunset \(sunset.formatted)", tint: Color(hex: Constants.Colors.goldMid))
                }
            }
            .padding(.top, 6)
        }
    }

    private var modePicker: some View {
        let options: [(Mode, String)] = [(.branch(.firstLook), "First look"), (.branch(.noFirstLook), "No first look"), (.compare, "Compare")]
        return HStack(spacing: 0) {
            ForEach(options.indices, id: \.self) { index in
                let option = options[index]
                let isSelected = resolvedMode == option.0
                Button(action: {
                    HapticManager.shared.buttonTap()
                    withAnimation(.easeInOut(duration: 0.2)) { mode = option.0 }
                }) {
                    Text(option.1)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isSelected ? TimelineStyle.text : TimelineStyle.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isSelected ? Color.white : Color.clear)
                                .shadow(color: isSelected ? .black.opacity(0.06) : .clear, radius: 4, x: 0, y: 2)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(4)
        .background(RoundedRectangle(cornerRadius: 10).fill(TimelineStyle.border.opacity(0.6)))
    }

    // MARK: - Warnings & notes

    private func warnings(_ warnings: [TimelineWarning]) -> some View {
        VStack(spacing: 10) {
            ForEach(warnings) { warning in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#B45309"))
                        .padding(.top, 2)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(warning.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(hex: "#7C2D12"))
                        Text(warning.message)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#7C2D12").opacity(0.85))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color(hex: "#FFF4E5")))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "#F5D9B0"), lineWidth: 1))
            }
        }
    }

    @ViewBuilder
    private var rainPlan: some View {
        if q.hasOutdoorPortion == true, let plan = q.rainPlan?.trimmingCharacters(in: .whitespacesAndNewlines), !plan.isEmpty {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "cloud.rain.fill")
                    .foregroundColor(TimelineStyle.ink)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Rain plan")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(TimelineStyle.text)
                    Text(plan)
                        .font(.system(size: 14))
                        .foregroundColor(TimelineStyle.secondary)
                }
                Spacer(minLength: 0)
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14).fill(TimelineStyle.cream))
        }
    }

    // MARK: - The day

    private func dayTimeline(_ result: TimelineResult) -> some View {
        let visible = result.visibleItems
        let groups = TimelinePhase.allCases.compactMap { phase -> (TimelinePhase, [TimelineItem])? in
            let items = visible.filter { result.phase(of: $0) == phase }
            return items.isEmpty ? nil : (phase, items)
        }

        return VStack(alignment: .leading, spacing: 22) {
            Text("Tap any line to adjust its time.")
                .font(.system(size: 13))
                .foregroundColor(TimelineStyle.secondary)

            ForEach(groups.indices, id: \.self) { groupIndex in
                let (phase, items) = groups[groupIndex]
                VStack(alignment: .leading, spacing: 0) {
                    Text(phase.title)
                        .font(TimelineStyle.title(24))
                        .foregroundColor(TimelineStyle.ink)
                        .padding(.bottom, 10)

                    VStack(spacing: 0) {
                        ForEach(items.indices, id: \.self) { index in
                            TimelineRow(item: items[index], isLast: index == items.count - 1) {
                                HapticManager.shared.buttonTap()
                                editingItem = items[index]
                            }
                        }
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(TimelineStyle.card)
                            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 3)
                    )
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(TimelineStyle.border, lineWidth: 1))
                }
            }
        }
    }

    @ViewBuilder
    private func hiddenItems(_ result: TimelineResult) -> some View {
        let hidden = result.hiddenItems
        if !hidden.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Button(action: {
                    withAnimation { showHidden.toggle() }
                }) {
                    HStack {
                        Image(systemName: showHidden ? "chevron.down" : "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                        Text("\(hidden.count) hidden \(hidden.count == 1 ? "line" : "lines")")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .foregroundColor(TimelineStyle.secondary)
                }
                .buttonStyle(PlainButtonStyle())

                if showHidden {
                    ForEach(hidden) { item in
                        HStack {
                            Text(item.label)
                                .font(.system(size: 15))
                                .foregroundColor(TimelineStyle.secondary)
                                .strikethrough()
                            Spacer()
                            Button("Restore") {
                                HapticManager.shared.buttonTap()
                                store.setHidden(false, for: item.id)
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(TimelineStyle.rose)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func weekend(_ result: TimelineResult) -> some View {
        if !result.weekend.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("The rest of the weekend")
                    .font(TimelineStyle.title(24))
                    .foregroundColor(TimelineStyle.ink)

                VStack(spacing: 0) {
                    ForEach(result.weekend.indices, id: \.self) { index in
                        let item = result.weekend[index]
                        HStack(alignment: .top, spacing: 14) {
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(item.date.map(TimelineDate.display) ?? "Date TBD")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(TimelineStyle.text)
                                if let time = item.time {
                                    Text(time.formatted)
                                        .font(.system(size: 13))
                                        .foregroundColor(TimelineStyle.secondary)
                                        .monospacedDigit()
                                }
                            }
                            .frame(width: 92, alignment: .trailing)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(TimelineStyle.text)
                                if let place = item.place, !place.isEmpty {
                                    Text(place)
                                        .font(.system(size: 13))
                                        .foregroundColor(TimelineStyle.secondary)
                                }
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(.vertical, 10)
                        if index < result.weekend.count - 1 {
                            Divider()
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 4)
                .background(RoundedRectangle(cornerRadius: 18).fill(TimelineStyle.card))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(TimelineStyle.border, lineWidth: 1))
            }
        }
    }

    private var bookACallCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Want a planner to look this over?")
                .font(TimelineStyle.title(24))
                .foregroundColor(TimelineStyle.ink)
            Text("Book a call with Jamie or Heather and they'll walk through your timeline with you.")
                .font(.system(size: 15))
                .foregroundColor(TimelineStyle.secondary)
                .fixedSize(horizontal: false, vertical: true)
            PrimaryButton(title: "Book a Call with a Planner") {
                showBookACall = true
            }
            .padding(.top, 4)
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 18).fill(TimelineStyle.cream))
    }
}

// MARK: - Row

struct TimelineRow: View {
    let item: TimelineItem
    let isLast: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                Text(item.time.formatted)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(TimelineStyle.text)
                    .monospacedDigit()
                    .frame(width: 68, alignment: .trailing)
                    .padding(.top, 1)

                VStack(spacing: 0) {
                    marker
                        .frame(width: 14, height: 18)
                    if !isLast {
                        Rectangle()
                            .fill(TimelineStyle.border)
                            .frame(width: 2)
                            .frame(maxHeight: .infinity)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(item.label)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(TimelineStyle.text)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        if item.isEdited {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 13))
                                .foregroundColor(TimelineStyle.rose)
                        }
                    }
                    if let detail = item.detail {
                        Text(detail)
                            .font(.system(size: 13))
                            .foregroundColor(TimelineStyle.secondary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    TrackTag(item: item)
                }
                .padding(.bottom, isLast ? 6 : 16)

                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.top, 6)
    }

    @ViewBuilder
    private var marker: some View {
        if item.id == "sunset" || item.id == "couple.sunsetPhotos" {
            Image(systemName: "sun.horizon.fill")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: Constants.Colors.goldMid))
        } else {
            Circle()
                .fill(TrackPalette.colors(for: item.track).foreground)
                .frame(width: 10, height: 10)
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
        }
    }
}

enum TrackPalette {
    static func colors(for track: TimelineTrack) -> (background: Color, foreground: Color) {
        switch track {
        case .partner(let id):
            return id == "p1"
                ? (Color(hex: "#F7E4E6"), Color(hex: "#A3545D"))
                : (Color(hex: "#E3E8EE"), Color(hex: "#4C5C6B"))
        case .couple:
            return (Color(hex: "#FBF0D9"), Color(hex: "#9A6400"))
        case .guests:
            return (Color(hex: "#E5EFE7"), Color(hex: "#4E7A5A"))
        case .vendor:
            return (Color(hex: "#EEF0F3"), Color(hex: "#4A5565"))
        case .everyone:
            return (Color(hex: "#FAF8F3"), Color(hex: "#364153"))
        }
    }
}

struct TrackTag: View {
    let item: TimelineItem

    var body: some View {
        let colors = TrackPalette.colors(for: item.track)
        Text(item.trackName)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(colors.foreground)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(colors.background))
    }
}

struct InfoChip: View {
    let icon: String
    let text: String
    var tint: Color = TimelineStyle.rose

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(tint)
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(TimelineStyle.text)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(TimelineStyle.cream))
        .overlay(Capsule().stroke(TimelineStyle.border, lineWidth: 1))
    }
}

// MARK: - Editing a line

struct TimelineItemEditor: View {
    let item: TimelineItem
    @ObservedObject var store: TimelineStore
    let onEditAnswers: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var time: Date

    init(item: TimelineItem, store: TimelineStore, onEditAnswers: @escaping () -> Void) {
        self.item = item
        self.store = store
        self.onEditAnswers = onEditAnswers
        _time = State(initialValue: item.time.date())
    }

    /// The picked clock time, kept on the same side of midnight as the original.
    private var pickedTime: TimeOfDay {
        let picked = TimeOfDay(date: time).minutes
        let candidates = [picked - 1440, picked, picked + 1440]
        let closest = candidates.min { abs($0 - item.time.minutes) < abs($1 - item.time.minutes) } ?? picked
        return TimeOfDay(minutes: closest)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.label)
                            .font(TimelineStyle.title(28))
                            .foregroundColor(TimelineStyle.ink)
                        if let detail = item.detail {
                            Text(detail)
                                .font(.system(size: 14))
                                .foregroundColor(TimelineStyle.secondary)
                        }
                        TrackTag(item: item)
                    }

                    if item.isEditable {
                        DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .frame(maxWidth: .infinity)

                        Text(item.sequenceId != nil
                             ? "The moments after this one move with it."
                             : "Lines timed from this one move with it.")
                            .font(.system(size: 13))
                            .foregroundColor(TimelineStyle.secondary)

                        if item.isEdited {
                            Button(action: {
                                HapticManager.shared.buttonTap()
                                store.resetTime(for: item.id)
                                dismiss()
                            }) {
                                Label("Reset to suggested time", systemImage: "arrow.uturn.backward")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(TimelineStyle.rose)
                            }
                        }

                        Button(action: {
                            HapticManager.shared.buttonTap()
                            store.setHidden(true, for: item.id)
                            dismiss()
                        }) {
                            Label("Hide this line", systemImage: "eye.slash")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(TimelineStyle.secondary)
                        }
                    } else {
                        Text(item.kind == .lookup
                             ? "Sunset comes from your wedding date and ceremony location."
                             : "This time comes from your answers.")
                            .font(.system(size: 15))
                            .foregroundColor(TimelineStyle.secondary)
                        SecondaryButton(title: "Edit answers") {
                            dismiss()
                            onEditAnswers()
                        }
                    }
                }
                .padding(20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(TimelineStyle.secondary)
                }
                if item.isEditable {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            HapticManager.shared.buttonTap()
                            if pickedTime != item.time {
                                store.setTime(pickedTime, for: item.id)
                            }
                            dismiss()
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(TimelineStyle.rose)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Reordering moments

struct ReorderMomentsView: View {
    @ObservedObject var store: TimelineStore
    let sequences: [TimelineSequence]

    @Environment(\.dismiss) private var dismiss
    @State private var orders: [String: [TimelineSequence.Entry]]

    init(store: TimelineStore, sequences: [TimelineSequence]) {
        self.store = store
        self.sequences = sequences
        _orders = State(initialValue: Dictionary(uniqueKeysWithValues: sequences.map { ($0.id, $0.entries) }))
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(sequences) { sequence in
                    Section {
                        ForEach(orders[sequence.id] ?? []) { entry in
                            HStack {
                                Text(entry.label)
                                    .font(.system(size: 16))
                                    .foregroundColor(entry.isFixed ? TimelineStyle.secondary : TimelineStyle.text)
                                Spacer()
                                if entry.isFixed {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(TimelineStyle.secondary.opacity(0.6))
                                }
                            }
                            .moveDisabled(entry.isFixed)
                        }
                        .onMove { source, destination in
                            move(in: sequence, from: source, to: destination)
                        }
                    } header: {
                        Text(sequence.title)
                    } footer: {
                        Button("Reset to suggested order") {
                            store.resetOrder(sequence)
                            dismiss()
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(TimelineStyle.rose)
                        .padding(.top, 4)
                    }
                }
            }
            .environment(\.editMode, .constant(.active))
            .navigationTitle("Reorder moments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(TimelineStyle.secondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        HapticManager.shared.buttonTap()
                        for sequence in sequences {
                            let ids = (orders[sequence.id] ?? []).map(\.id)
                            if ids != sequence.entries.map(\.id) {
                                store.saveOrder(ids)
                            }
                        }
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(TimelineStyle.rose)
                }
            }
        }
    }

    /// Introductions stay first and the open dance floor stays last.
    private func move(in sequence: TimelineSequence, from source: IndexSet, to destination: Int) {
        guard var entries = orders[sequence.id] else { return }
        let original = entries
        entries.move(fromOffsets: source, toOffset: destination)
        if let first = original.first, first.isFixed, entries.first != first { return }
        if let last = original.last, last.isFixed, entries.last != last { return }
        orders[sequence.id] = entries
    }
}

// MARK: - Show me both

struct TimelineCompareView: View {
    let firstLook: TimelineResult
    let noFirstLook: TimelineResult
    let onChoose: (FirstLookBranch) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Here's your day both ways. Pick the one that feels right; you can switch anytime in your answers.")
                .font(.system(size: 15))
                .foregroundColor(TimelineStyle.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .top, spacing: 10) {
                column(firstLook)
                column(noFirstLook)
            }
        }
    }

    private func facts(_ result: TimelineResult) -> [(String, String)] {
        var facts: [(String, String)] = []
        if let first = result.visibleItems.first {
            facts.append(("Day starts", first.time.formatted))
        }
        if let hairMakeup = result.visibleItems.filter({ $0.id.hasSuffix(".hmuStart") }).map(\.time).min() {
            facts.append(("Hair & makeup", hairMakeup.formatted))
        }
        facts.append(("Photos", result.branch == .firstLook ? "Before the ceremony" : "After the ceremony"))
        if result.branch == .firstLook {
            facts.append(("Cocktail hour", "You're there the whole time"))
        } else if let joins = result.item("couple.joinsCocktail") {
            facts.append(("Cocktail hour", "You join at \(joins.time.formatted)"))
        } else {
            facts.append(("Cocktail hour", "Mostly photos"))
        }
        facts.append(("Heads-ups", result.warnings.isEmpty ? "None" : "\(result.warnings.count)"))
        return facts
    }

    private func column(_ result: TimelineResult) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(result.branch.label)
                .font(TimelineStyle.title(22))
                .foregroundColor(TimelineStyle.ink)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(facts(result).indices, id: \.self) { index in
                    let fact = facts(result)[index]
                    VStack(alignment: .leading, spacing: 1) {
                        Text(fact.0.uppercased())
                            .font(.system(size: 9, weight: .bold))
                            .tracking(0.4)
                            .foregroundColor(TimelineStyle.secondary)
                        Text(fact.1)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(TimelineStyle.text)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            Button(action: { onChoose(result.branch) }) {
                Text("Choose this")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(RoundedRectangle(cornerRadius: 12).fill(TimelineStyle.ink))
            }
            .buttonStyle(PlainButtonStyle())

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                ForEach(result.visibleItems) { item in
                    VStack(alignment: .leading, spacing: 1) {
                        Text(item.time.formatted)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(TrackPalette.colors(for: item.track).foreground)
                            .monospacedDigit()
                        Text(compactLabel(item))
                            .font(.system(size: 12))
                            .foregroundColor(TimelineStyle.text)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(RoundedRectangle(cornerRadius: 16).fill(TimelineStyle.card))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(TimelineStyle.border, lineWidth: 1))
    }

    private func compactLabel(_ item: TimelineItem) -> String {
        if case .partner = item.track { return "\(item.trackName): \(item.label)" }
        return item.label
    }
}
