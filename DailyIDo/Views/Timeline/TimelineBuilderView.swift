import SwiftUI

/// Full-screen Timeline Builder: intro → questionnaire → generated timeline.
struct TimelineBuilderView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = TimelineStore.shared
    /// Non-nil while the questionnaire is showing (the page to open on).
    @State private var questionnairePage: Int?
    @AppStorage("timeline.lastQuestionnairePage") private var lastPage = 0

    private var isEditingAnswers: Bool { questionnairePage != nil && store.isBuilt }

    var body: some View {
        NavigationStack {
            Group {
                if !store.isLoaded {
                    LoadingSpinner()
                } else if let page = questionnairePage {
                    TimelineQuestionnaireView(store: store, startPage: page) {
                        build()
                    }
                    .id(page)
                } else if store.isBuilt {
                    TimelineDayView(store: store) {
                        questionnairePage = 0
                    }
                } else {
                    TimelineIntroView(store: store, onStart: start, onBuild: build)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        HapticManager.shared.buttonTap()
                        if isEditingAnswers {
                            // Answers save as they're made; go straight back to the timeline.
                            withAnimation { questionnairePage = nil }
                        } else {
                            dismiss()
                        }
                    }) {
                        if isEditingAnswers {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Timeline")
                                    .font(.system(size: 16))
                            }
                            .foregroundColor(TimelineStyle.ink)
                        } else {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(TimelineStyle.ink)
                        }
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Timeline Builder")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(TimelineStyle.ink)
                }
            }
            .onChange(of: questionnairePage) { page in
                if let page { lastPage = page }
            }
        }
        .task {
            await store.load()
        }
    }

    private func start() {
        if !store.hasStarted {
            AnalyticsService.shared.logTimelineQuestionnaireStarted()
            lastPage = 0
        }
        withAnimation { questionnairePage = lastPage }
    }

    private func build() {
        HapticManager.shared.success()
        store.markBuilt()
        withAnimation { questionnairePage = nil }
    }
}

struct TimelineIntroView: View {
    @ObservedObject var store: TimelineStore
    let onStart: () -> Void
    let onBuild: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image("champagne-glasses")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 130)
                    .padding(.top, 12)

                VStack(spacing: 10) {
                    Text("Your wedding day,\nminute by minute")
                        .font(TimelineStyle.title(36))
                        .foregroundColor(TimelineStyle.ink)
                        .multilineTextAlignment(.center)

                    Text("Answer a few questions and we'll build your wedding-day timeline the way Jamie & Heather plan their couples' days.")
                        .font(.system(size: 16))
                        .foregroundColor(TimelineStyle.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(alignment: .leading, spacing: 14) {
                    feature("clock.fill", "Hair & makeup through the last dance")
                    feature("sun.horizon.fill", "Sunset photos timed to your venue")
                    feature("arrow.left.arrow.right", "Undecided on a first look? See your day both ways")
                    feature("hand.tap.fill", "Adjust any time, and everything after it follows")
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 18).fill(TimelineStyle.cream))

                VStack(spacing: 12) {
                    PrimaryButton(title: store.hasStarted ? "Continue" : "Get started", action: onStart)
                    if store.hasStarted && store.questionnaire.isReadyToBuild {
                        SecondaryButton(title: "Build with what I've answered", action: onBuild)
                    }
                    Text("Only 6 questions are required · about 5–10 minutes")
                        .font(.system(size: 13))
                        .foregroundColor(TimelineStyle.secondary)
                }
            }
            .padding(24)
        }
        .background(Color(hex: Constants.Colors.background).ignoresSafeArea())
    }

    private func feature(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(TimelineStyle.rose)
                .frame(width: 24)
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(TimelineStyle.text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    TimelineBuilderView()
}
