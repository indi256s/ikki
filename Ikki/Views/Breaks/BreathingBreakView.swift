import SwiftUI

struct BreathingBreakView: View {
    let viewModel: BreakViewModel
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            // Header
            Text(viewModel.breathingTechnique?.displayName ?? "Breathing")
                .font(AppTypography.breakCaption)
                .foregroundStyle(AppColors.textSecondary)
                .accessibilityAddTraits(.isHeader)

            // Main Animation
            PulsingCircleView(
                scale: viewModel.animationScale,
                phaseDuration: viewModel.phaseDuration
            )
            .frame(height: 200)
            .accessibilityHidden(true)

            // Content
            VStack(spacing: AppSpacing.sm) {
                PhaseLabel(text: viewModel.currentPhaseLabel)
                    .accessibilityLabel("Current phase")
                    .accessibilityValue(viewModel.currentPhaseLabel)
                
                Text(String(format: "%.0f", viewModel.remainingPhaseSeconds))
                    .font(AppTypography.breakCountdown)
                    .foregroundStyle(AppColors.textPrimary)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .accessibilityLabel("Remaining seconds in phase")
                    .accessibilityValue(String(format: "%.0f", viewModel.remainingPhaseSeconds))
            }

            // Footer
            HStack {
                Text(viewModel.cycleLabel)
                    .accessibilityLabel("Cycle count")
                Spacer()
                Text(String(format: "%.0f remaining", viewModel.totalRemainingSeconds))
                    .accessibilityLabel("Total time remaining")
            }
            .font(AppTypography.breakCaption)
            .foregroundStyle(AppColors.textTertiary)
            .padding(.horizontal, AppSpacing.lg)

            // Dismiss
            Button("Dismiss") {
                onDismiss()
            }
            .buttonStyle(.plain)
            .font(AppTypography.popoverCaption)
            .foregroundStyle(AppColors.textSecondary)
            .keyboardShortcut(.cancelAction)
            .accessibilityLabel("Dismiss break")
            .accessibilityHint("Stop the current session and close the window.")
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(viewModel.breathingTechnique?.displayName ?? "Breathing") session in progress.")
    }
}
