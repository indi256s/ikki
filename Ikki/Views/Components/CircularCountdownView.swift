import SwiftUI

struct CircularCountdownView: View {
    var totalSeconds: Double
    var remainingSeconds: Double
    var lineWidth: CGFloat = 4
    var size: CGFloat = 120

    private var progress: Double {
        totalSeconds > 0 ? remainingSeconds / totalSeconds : 0
    }

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(AppColors.textTertiary.opacity(0.15), lineWidth: lineWidth)

            // Progress
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AppColors.accent,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: remainingSeconds)

            // Center text
            Text(String(format: "%.0f", remainingSeconds))
                .font(AppTypography.breakCountdown)
                .foregroundStyle(AppColors.textPrimary)
                .contentTransition(.numericText())
        }
        .frame(width: size, height: size)
    }
}
