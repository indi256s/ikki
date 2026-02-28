import SwiftUI

struct PulsingCircleView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var scale: CGFloat              // 0.3–1.0
    var phaseDuration: Double       // Animation duration
    var color: Color = AppColors.accent

    var body: some View {
        ZStack {
            // Layer 3: Glow (outermost)
            if !reduceMotion {
                Circle()
                    .fill(color.opacity(0.12))
                    .blur(radius: 20)
                    .scaleEffect(scale)
                    .animation(.timingCurve(0.4, 0.0, 0.2, 1.0, duration: phaseDuration).delay(0.1), value: scale)
            }

            // Layer 2: Ring
            Circle()
                .stroke(color.opacity(0.35), lineWidth: 2)
                .scaleEffect(scale)
                .animation(reduceMotion ? .none : .timingCurve(0.4, 0.0, 0.2, 1.0, duration: phaseDuration).delay(0.05), value: scale)

            // Layer 1: Fill (innermost)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.8), color.opacity(0.4)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 90
                    )
                )
                .scaleEffect(scale)
                .animation(reduceMotion ? .none : .timingCurve(0.4, 0.0, 0.2, 1.0, duration: phaseDuration), value: scale)
        }
        .frame(width: 180, height: 180)
    }
}
