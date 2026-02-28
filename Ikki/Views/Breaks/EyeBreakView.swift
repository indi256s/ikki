import SwiftUI

struct EyeBreakView: View {
    let viewModel: BreakViewModel
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            // Header
            Text(viewModel.eyeTechnique?.displayName ?? "Eye Rest")
                .font(AppTypography.breakCaption)
                .foregroundStyle(AppColors.textSecondary)
                .accessibilityAddTraits(.isHeader)

            // Main Animation
            CircularCountdownView(
                totalSeconds: Double(EyeTechnique.twentyTwentyTwenty.totalDurationSeconds),
                remainingSeconds: viewModel.remainingPhaseSeconds,
                size: 180
            )
            .accessibilityLabel("Time remaining")
            .accessibilityValue("\(Int(viewModel.remainingPhaseSeconds)) seconds")

            // Content
            VStack(spacing: AppSpacing.sm) {
                Text("Look at something 6 meters (20 feet) away")
                    .font(AppTypography.breakPhaseLabel)
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.lg)
            }

            // Footer
            Spacer()
            
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
        .accessibilityLabel("\(viewModel.eyeTechnique?.displayName ?? "Eye Rest") session in progress. Look at something 6 meters away.")
    }
}
