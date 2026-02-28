import SwiftUI

struct BreakContainerView: View {
    let viewModel: BreakViewModel
    var onDismiss: () -> Void

    /// The actual session length in seconds — used as the progress denominator.
    /// Falls back to `type.defaultDurationSeconds` only when no technique is set.
    private var sessionDuration: Int {
        if let b = viewModel.breathingTechnique { return b.totalDurationSeconds }
        if let e = viewModel.eyeTechnique { return e.totalDurationSeconds }
        return viewModel.type.defaultDurationSeconds
    }

    var body: some View {
        ZStack {
            // Background material
            VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                .ignoresSafeArea()

            // Header progress bar (total break progress)
            VStack(spacing: 0) {
                GeometryReader { geo in
                    Rectangle()
                        .fill(AppColors.accent)
                        .frame(width: geo.size.width * CGFloat(
                            sessionDuration > 0
                            ? 1.0 - (Double(viewModel.totalRemainingSeconds) / Double(sessionDuration))
                            : 1.0
                        ))
                        .animation(.linear(duration: 0.1), value: viewModel.totalRemainingSeconds)
                }
                .frame(height: 3)
                
                Spacer()
            }

            // Route to correct view
            Group {
                switch viewModel.type {
                case .breathing:
                    BreathingBreakView(viewModel: viewModel, onDismiss: onDismiss)
                case .eye:
                    EyeBreakView(viewModel: viewModel, onDismiss: onDismiss)
                case .blinkReset:
                    BlinkResetView(viewModel: viewModel, onDismiss: onDismiss)
                case .focusShift:
                    FocusShiftView(viewModel: viewModel, onDismiss: onDismiss)
                }
            }
        }
    }
}

// Utility for background material
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
