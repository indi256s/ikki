import SwiftUI

struct PhaseLabel: View {
    var text: String              // "Inhale", "Hold", "Exhale"
    var foregroundColor: Color = AppColors.textPrimary

    var body: some View {
        Text(text)
            .font(AppTypography.breakPhaseLabel)
            .foregroundStyle(foregroundColor)
            .contentTransition(.opacity)
            .animation(AppAnimations.phaseSwap, value: text)
    }
}
