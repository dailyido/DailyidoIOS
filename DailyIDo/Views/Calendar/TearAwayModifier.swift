import SwiftUI

struct TearAwayModifier: ViewModifier {
    let offset: CGFloat
    let isDragging: Bool
    let hasSnapped: Bool
    let progress: CGFloat
    let opacity: Double

    // Direction of swipe
    private var isSwipingLeft: Bool {
        offset < 0
    }

    // MARK: - 3D Peel Effect

    // Y-axis rotation: Makes the right edge come toward you (like opening a book from the right)
    // This creates the "corner lifting toward you" effect
    private var yRotation: Double {
        guard abs(offset) > 0 else { return 0 }

        let eased = easeOutCubic(progress)
        let maxAngle: Double = hasSnapped ? 50 : 25

        // Negative Y rotation brings the right side toward viewer
        return -Double(eased) * maxAngle * (isSwipingLeft ? 1 : -1)
    }

    // X-axis rotation: Makes the top edge tilt away (page peeling backward)
    // This kicks in more after the corner lifts
    private var xRotation: Double {
        guard abs(offset) > 0 else { return 0 }

        // Start X rotation after some progress
        let delayedProgress = max(0, progress - 0.2) / 0.8
        let eased = easeOutCubic(delayedProgress)
        let maxAngle: Double = hasSnapped ? 40 : 15

        // Positive X rotation tilts the top away from viewer
        return Double(eased) * maxAngle
    }

    // Minimal horizontal movement - let the 3D rotation do the work
    private var horizontalOffset: CGFloat {
        if hasSnapped {
            return progress * (isSwipingLeft ? -100 : 100)
        }
        return offset * 0.15
    }

    // Page lifts up slightly as it peels
    private var verticalOffset: CGFloat {
        guard abs(offset) > 0 else { return 0 }
        return -progress * (hasSnapped ? 60 : 20)
    }

    // Scale
    private var scale: CGFloat {
        if hasSnapped && isDragging && progress < 0.5 {
            return Constants.TearAnimation.snapScalePop
        }
        return 1.0 - (progress * 0.02)
    }

    // Shadow - appears under the lifted page
    private var shadowRadius: CGFloat {
        8 + (progress * 20)
    }

    private var shadowOpacity: Double {
        0.1 + (Double(progress) * 0.25)
    }

    private func easeOutCubic(_ t: CGFloat) -> CGFloat {
        let t1 = t - 1
        return t1 * t1 * t1 + 1
    }

    func body(content: Content) -> some View {
        content
            .offset(x: horizontalOffset, y: verticalOffset)
            // Y rotation: right edge lifts toward viewer
            .rotation3DEffect(
                .degrees(yRotation),
                axis: (x: 0, y: 1, z: 0),
                anchor: isSwipingLeft ? .leading : .trailing,
                perspective: 0.8
            )
            // X rotation: top peels backward
            .rotation3DEffect(
                .degrees(xRotation),
                axis: (x: 1, y: 0, z: 0),
                anchor: .bottom,
                perspective: 0.8
            )
            .scaleEffect(scale, anchor: .bottom)
            .shadow(
                color: .black.opacity(shadowOpacity),
                radius: shadowRadius,
                x: 0,
                y: 8 + (progress * 12)
            )
            .opacity(opacity)
    }
}

// MARK: - Animation Extensions

extension Animation {
    static var backgroundRise: Animation {
        .interactiveSpring(
            response: Constants.TearAnimation.backgroundRiseResponse,
            dampingFraction: Constants.TearAnimation.backgroundRiseDamping
        )
    }
}
