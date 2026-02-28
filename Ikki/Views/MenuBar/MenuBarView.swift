import SwiftUI

struct MenuBarView: View {
    @State var viewModel: MenuBarViewModel
    var onOpenSettings: () -> Void
    var onQuit: () -> Void

    private let presets = [20, 25, 40, 52]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: viewModel.menuBarIcon)
                    .foregroundStyle(AppColors.accent)
                    .accessibilityHidden(true)
                Text("Ikki")
                    .font(AppTypography.popoverTitle)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Text(viewModel.timerService.state == .fired ? "Break Time!" : "")
                    .font(AppTypography.popoverCaption)
                    .foregroundStyle(AppColors.accent)
                    .accessibilityLabel("Status")
                    .accessibilityValue(viewModel.timerService.state == .fired ? "Break Time!" : "Ready")
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.lg)
            .padding(.bottom, AppSpacing.md)

            // Timer Display
            VStack(spacing: AppSpacing.sm) {
                Text(viewModel.timerService.remainingFormatted)
                    .font(AppTypography.breakCountdown)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .accessibilityLabel("Time remaining")
                    .accessibilityValue(viewModel.timerService.remainingFormatted)
                
                // Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(AppColors.textTertiary.opacity(0.1))
                            .frame(height: 4)
                        
                        Capsule()
                            .fill(AppColors.accent)
                            .frame(width: geo.size.width * CGFloat(viewModel.timerService.progress), height: 4)
                            .animation(.linear(duration: 1), value: viewModel.timerService.progress)
                    }
                }
                .frame(height: 4)
                .padding(.horizontal, AppSpacing.xl)
                .accessibilityLabel("Work progress")
                .accessibilityValue("\(Int(viewModel.timerService.progress * 100)) percent")
            }
            .padding(.vertical, AppSpacing.lg)

            // Presets
            VStack(spacing: AppSpacing.md) {
                HStack(spacing: AppSpacing.sm) {
                    ForEach(presets, id: \.self) { minutes in
                        PresetButton(
                            minutes: minutes,
                            isSelected: viewModel.selectedPresetMinutes == minutes,
                            action: { viewModel.selectPreset(minutes) }
                        )
                    }
                }
                
                PresetButton(
                    minutes: viewModel.customMinutes,
                    label: "Custom: \(viewModel.customMinutes)m",
                    isSelected: viewModel.selectedPresetMinutes == viewModel.customMinutes,
                    action: { viewModel.selectPreset(viewModel.customMinutes) }
                )
            }
            .padding(.horizontal, AppSpacing.lg)

            Spacer(minLength: AppSpacing.lg)

            // Main Controls
            VStack(spacing: AppSpacing.sm) {
                Button {
                    viewModel.toggleTimer()
                } label: {
                    HStack {
                        Image(systemName: timerButtonIcon)
                        Text(timerButtonTitle)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.sm)
                    .background(AppColors.accent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: AppCorners.md))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(timerButtonTitle)
                .accessibilityHint("Start, pause, or resume the work timer.")

                HStack(spacing: AppSpacing.xl) {
                    Button("Stop") {
                        viewModel.stopTimer()
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(AppColors.textSecondary)
                    .accessibilityHint("Stop the timer and reset it to the selected interval.")

                    Button("Reset") {
                        viewModel.resetTimer()
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(AppColors.textSecondary)
                    .accessibilityHint("Restart the timer with the current interval.")
                }
                .font(AppTypography.popoverCaption)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.bottom, AppSpacing.lg)

            Divider()
                .opacity(0.2)

            // System Actions
            HStack {
                Button {
                    onOpenSettings()
                } label: {
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: "gearshape")
                        Text("Settings")
                    }
                }
                .buttonStyle(.plain)
                .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Button {
                    onQuit()
                } label: {
                    HStack(spacing: AppSpacing.sm) {
                        Text("Quit")
                        Text("⌘Q").opacity(0.5)
                    }
                }
                .buttonStyle(.plain)
                .foregroundStyle(AppColors.textSecondary)
            }
            .font(AppTypography.popoverCaption)
            .padding(AppSpacing.lg)
        }
        .frame(width: AppConstants.popoverWidth)
        .background(VisualEffectView(material: .ultraThinMaterial, blendingMode: .withinWindow))
    }

    private var timerButtonTitle: String {
        switch viewModel.timerService.state {
        case .idle, .fired: return "Start Timer"
        case .running: return "Pause"
        case .paused: return "Resume"
        case .onBreak: return "On Break"
        }
    }

    private var timerButtonIcon: String {
        switch viewModel.timerService.state {
        case .idle, .fired: return "play.fill"
        case .running: return "pause.fill"
        case .paused: return "play.fill"
        case .onBreak: return "heart.fill"
        }
    }
}

struct PresetButton: View {
    let minutes: Int
    var label: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label ?? "\(minutes)m")
                .font(AppTypography.popoverCaption)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.xs)
                .background(isSelected ? AppColors.accent : AppColors.surfaceHover)
                .foregroundStyle(isSelected ? .white : AppColors.textPrimary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label ?? "\(minutes) minutes")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint("Select \(minutes) minutes as the work interval.")
    }
}
