import SwiftUI

struct TutorialView: View {
    @Binding var isPresented: Bool
    @State private var currentStep = 0

    // Check if user is > 440 days out for long engagement message
    private var isLongEngagement: Bool {
        guard let user = AuthService.shared.currentUser,
              let weddingDate = user.weddingDate else {
            return false
        }
        return Date().daysUntil(weddingDate) > 440
    }

    // Check if user doesn't have a wedding date set
    private var hasNoWeddingDate: Bool {
        AuthService.shared.currentUser?.weddingDate == nil
    }

    private var steps: [TutorialStep] {
        var baseSteps = [
            TutorialStep(
                icon: "heart.fill",
                title: "Welcome to Daily I Do!",
                description: "Let's walk through how to use the app."
            ),
            TutorialStep(
                icon: "hand.draw",
                title: "Swipe for New Tips",
                description: "Swipe left on the calendar to tear away the page and reveal your next daily tip."
            ),
            TutorialStep(
                icon: "heart.fill",
                title: "Save Your Favorites",
                description: "Double-tap any tip to save it to your favorites. Find all your saved tips in the To-Do tab to revisit later!"
            ),
            TutorialStep(
                icon: "square.and.arrow.up",
                title: "Share Your Journey",
                description: "Tap the share button to post to Instagram Stories, text your fiancé, or share with your wedding party."
            ),
            TutorialStep(
                icon: "checklist",
                title: "Your Checklist",
                description: "Find your complete wedding checklist in the To-Do tab, organized by timeframe so you know what to focus on."
            ),
            TutorialStep(
                icon: "link",
                title: "Helpful Resources",
                description: "Some tips include links to curated resources and recommendations to help you along the way."
            ),
            TutorialStep(
                icon: "bell",
                title: "Set Reminders",
                description: "Tap the bell icon to save a tip to your Apple Reminders so you remember important tasks."
            ),
            TutorialStep(
                icon: "calendar.badge.clock",
                title: "Test it Out!",
                description: "We're starting you a few days back so you can swipe through and catch up to today. Each day unlocks a new wedding tip!"
            )
        ]

        // Add long engagement step for users > 440 days out
        if isLongEngagement {
            baseSteps.append(TutorialStep(
                icon: "sparkles",
                title: "You're Ahead of the Game!",
                description: "You're over 440 days out—perfect for big-picture planning. More detailed tips will unlock as you get closer (around 15 months out). Focus on the fun stuff first!"
            ))
        }

        // Add step for users without a wedding date
        if hasNoWeddingDate {
            baseSteps.append(TutorialStep(
                icon: "calendar.badge.plus",
                title: "Big Picture Planning",
                description: "While you work to set your date, we will share a mix of planning tips and fun facts. Be sure to add your wedding date in settings once you finalize!"
            ))
        }

        return baseSteps
    }

    private let primaryColor = Color(hex: Constants.Colors.buttonPrimary)
    private let accentColor = Color(hex: Constants.Colors.accent)
    private let secondaryText = Color(hex: Constants.Colors.secondaryText)

    var body: some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
            .overlay {
                // Tutorial card - centered via overlay
                VStack(spacing: 0) {
                    // Content
                    TabView(selection: $currentStep) {
                        ForEach(0..<steps.count, id: \.self) { index in
                            tutorialStepView(steps[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(minHeight: 320, maxHeight: 400)

                    // Page indicator
                    HStack(spacing: 8) {
                        ForEach(0..<steps.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentStep ? accentColor : accentColor.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .animation(.easeInOut(duration: 0.2), value: currentStep)
                        }
                    }
                    .padding(.top, 16)

                    // Button
                    Button(action: {
                        HapticManager.shared.buttonTap()
                        if currentStep < steps.count - 1 {
                            withAnimation {
                                currentStep += 1
                            }
                        } else {
                            dismissTutorial()
                        }
                    }) {
                        Text(currentStep < steps.count - 1 ? "Next" : "Let's Do This!")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(primaryColor)
                            )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                    // Skip button
                    if currentStep < steps.count - 1 {
                        Button(action: {
                            dismissTutorial()
                        }) {
                            Text("Skip")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(secondaryText)
                        }
                        .padding(.top, 12)
                    }
                }
                .padding(.vertical, 32)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                )
                .padding(.horizontal, 24)
            }
    }

    private func tutorialStepView(_ step: TutorialStep) -> some View {
        VStack(spacing: 20) {
            // Icon
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: step.icon)
                    .font(.system(size: 40))
                    .foregroundColor(accentColor)
            }

            // Title
            Text(step.title)
                .font(.custom("CormorantGaramond-Bold", size: 28))
                .foregroundColor(primaryColor)
                .multilineTextAlignment(.center)

            // Description
            Text(step.description)
                .font(.system(size: 16))
                .foregroundColor(secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 24)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 300)
    }

    private func dismissTutorial() {
        UserDefaults.standard.set(true, forKey: "hasSeenTutorial")
        withAnimation(.easeOut(duration: 0.3)) {
            isPresented = false
        }
    }
}

struct TutorialStep {
    let icon: String
    let title: String
    let description: String
}

#Preview {
    TutorialView(isPresented: .constant(true))
}
