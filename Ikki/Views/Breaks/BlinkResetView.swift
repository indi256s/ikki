import SwiftUI

struct BlinkResetView: View {
    let viewModel: BreakViewModel
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            // Header
            Text("Blink Reset")
                .font(AppTypography.breakCaption)
                .foregroundStyle(AppColors.textSecondary)
                .accessibilityAddTraits(.isHeader)

            // Eye Icon
            AnimatedEyeView(isOpen: viewModel.remainingPhaseSeconds < 1.5)
                .frame(height: 120)
                .accessibilityHidden(true)

            // Content
            VStack(spacing: AppSpacing.sm) {
                Text(viewModel.remainingPhaseSeconds < 1.5 ? "Open" : "Close")
                    .font(AppTypography.breakHeadline)
                    .foregroundStyle(AppColors.textPrimary)
                    .accessibilityLabel("Current instruction")
                    .accessibilityValue(viewModel.remainingPhaseSeconds < 1.5 ? "Open your eyes" : "Close your eyes")
                
                Text("Blink slowly and fully")
                    .font(AppTypography.breakPhaseLabel)
                    .foregroundStyle(AppColors.textSecondary)
            }

            // Footer
            HStack {
                Text("Blink \(viewModel.currentCycle) of 10")
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
        .accessibilityLabel("Blink reset session in progress. Blink slowly and fully.")
    }
}
