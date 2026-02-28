import SwiftUI

struct FocusShiftView: View {
    let viewModel: BreakViewModel
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            // Header
            Text("Focus Shift")
                .font(AppTypography.breakCaption)
                .foregroundStyle(AppColors.textSecondary)
                .accessibilityAddTraits(.isHeader)

            // Animation
            CircularCountdownView(
                totalSeconds: 5.0,
                remainingSeconds: viewModel.remainingPhaseSeconds,
                size: 180
            )
            .accessibilityLabel("Phase countdown")
            .accessibilityValue("\(Int(viewModel.remainingPhaseSeconds)) seconds")

            // Content
            VStack(spacing: AppSpacing.sm) {
                PhaseLabel(text: viewModel.currentPhaseLabel)
                    .accessibilityLabel("Current phase")
                    .accessibilityValue(viewModel.currentPhaseLabel)
                
                Text(viewModel.currentPhaseLabel.contains("NEAR") ? "Hold a finger at arm's length" : "Look at something 6m away")
                    .font(AppTypography.popoverBody)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            // Footer
            HStack {
                Text("Round \(viewModel.currentCycle) of 5")
                Spacer()
                Text(String(format: "%.0f remaining", viewModel.totalRemainingSeconds))
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
            .accessibilityLabel("Dismiss session")
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Focus shift session in progress. Alternate focus between near and far objects.")
    }
}
