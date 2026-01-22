import UIKit

final class HapticManager {
    static let shared = HapticManager()

    private let lightImpactGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpactGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()

    private init() {
        prepareGenerators()
    }

    func prepareGenerators() {
        lightImpactGenerator.prepare()
        mediumImpactGenerator.prepare()
        heavyImpactGenerator.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }

    func lightImpact() {
        lightImpactGenerator.impactOccurred()
        lightImpactGenerator.prepare()
    }

    func mediumImpact() {
        mediumImpactGenerator.impactOccurred()
        mediumImpactGenerator.prepare()
    }

    func heavyImpact() {
        heavyImpactGenerator.impactOccurred()
        heavyImpactGenerator.prepare()
    }

    func success() {
        notificationGenerator.notificationOccurred(.success)
        notificationGenerator.prepare()
    }

    func warning() {
        notificationGenerator.notificationOccurred(.warning)
        notificationGenerator.prepare()
    }

    func error() {
        notificationGenerator.notificationOccurred(.error)
        notificationGenerator.prepare()
    }

    func selection() {
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
    }

    // Convenience methods for specific actions
    func buttonTap() {
        lightImpact()
    }

    func swipeStart() {
        lightImpact()
    }

    func pageTear() {
        mediumImpact()
    }

    func pageSettle() {
        lightImpact()
    }

    func checklistComplete() {
        success()
    }

    func streakMilestone() {
        heavyImpact()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.success()
        }
    }

    func settingsSave() {
        lightImpact()
    }

    func validationError() {
        error()
    }

    // MARK: - Tear Animation Haptics

    /// Light texture feedback during resistance phase
    func tearResistance() {
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
    }

    /// Satisfying snap when perforations break
    func perforationSnap() {
        // Medium impact for the main snap
        mediumImpactGenerator.impactOccurred(intensity: 0.8)

        // Light "release" feeling shortly after
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.lightImpactGenerator.impactOccurred(intensity: 0.4)
            self?.lightImpactGenerator.prepare()
        }

        mediumImpactGenerator.prepare()
    }

    /// Heavy satisfying completion when tear finishes
    func tearComplete() {
        // Heavy impact for satisfaction
        heavyImpactGenerator.impactOccurred(intensity: 0.7)

        // Success notification shortly after
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.notificationGenerator.notificationOccurred(.success)
            self?.notificationGenerator.prepare()
        }

        heavyImpactGenerator.prepare()
    }

    /// Light feedback when tear is cancelled and card snaps back
    func tearCancel() {
        lightImpactGenerator.impactOccurred(intensity: 0.5)
        lightImpactGenerator.prepare()
    }

    // MARK: - Celebration Haptics

    /// Elaborate celebration sequence for streak milestones
    func celebrationEntrance() {
        // Initial heavy "ta-da" impact
        heavyImpactGenerator.impactOccurred(intensity: 1.0)
        heavyImpactGenerator.prepare()

        // Quick double-tap feeling
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.mediumImpactGenerator.impactOccurred(intensity: 0.7)
            self?.mediumImpactGenerator.prepare()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            self?.mediumImpactGenerator.impactOccurred(intensity: 0.8)
            self?.mediumImpactGenerator.prepare()
        }

        // Success flourish
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.notificationGenerator.notificationOccurred(.success)
            self?.notificationGenerator.prepare()
        }
    }

    /// Confetti burst haptic
    func confettiBurst() {
        // Rapid light taps to simulate confetti
        for i in 0..<5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.06) { [weak self] in
                self?.lightImpactGenerator.impactOccurred(intensity: CGFloat.random(in: 0.3...0.7))
                self?.lightImpactGenerator.prepare()
            }
        }
    }

    /// Heart pulse haptic (synced with visual heart animation)
    func heartPulse() {
        mediumImpactGenerator.impactOccurred(intensity: 0.6)
        mediumImpactGenerator.prepare()
    }

    /// Celebration dismiss haptic
    func celebrationDismiss() {
        // Gentle "goodbye" feeling
        lightImpactGenerator.impactOccurred(intensity: 0.5)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { [weak self] in
            self?.selectionGenerator.selectionChanged()
            self?.selectionGenerator.prepare()
        }
        lightImpactGenerator.prepare()
    }
}
