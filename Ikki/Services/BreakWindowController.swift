import AppKit
import SwiftUI

final class BreakWindowController: NSWindowController {
    static let shared = BreakWindowController()
    
    private var panel: NSPanel?

    init() {
        super.init(window: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showBreak(type: BreakType, technique: (any BreakTechnique)? = nil) {
        if panel != nil {
            dismiss()
        }

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: AppConstants.breakWindowWidth, height: AppConstants.breakWindowHeight),
            styleMask: [.nonactivatingPanel, .titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isMovableByWindowBackground = true
        panel.level = .floating
        panel.backgroundColor = .clear
        panel.isReleasedWhenClosed = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.hasShadow = true
        
        let viewModel = BreakViewModel(type: type, technique: technique) { [weak self] in
            self?.dismiss()
        }
        
        let containerView = BreakContainerView(viewModel: viewModel) { [weak self] in
            self?.dismiss()
        }
        
        let hostingView = NSHostingView(rootView: containerView)
        panel.contentView = hostingView
        
        // Center on the screen the user is working on (cursor screen, not always NSScreen.main)
        let mouseLocation = NSEvent.mouseLocation
        let screen = NSScreen.screens.first(where: { $0.frame.contains(mouseLocation) }) ?? NSScreen.main
        if let screen = screen {
            let screenRect = screen.visibleFrame
            let x = screenRect.origin.x + (screenRect.width - AppConstants.breakWindowWidth) / 2
            let y = screenRect.origin.y + (screenRect.height - AppConstants.breakWindowHeight) / 2
            panel.setFrame(NSRect(x: x, y: y, width: AppConstants.breakWindowWidth, height: AppConstants.breakWindowHeight), display: true)
        }

        self.panel = panel
        viewModel.start()
        
        panel.alphaValue = 0
        panel.makeKeyAndOrderFront(nil)
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = AppConstants.windowFadeDuration
            panel.animator().alphaValue = 1
        })
    }

    func dismiss() {
        guard let panel = panel else { return }
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = AppConstants.windowDismissDuration
            panel.animator().alphaValue = 0
        }) { [weak self] in
            panel.orderOut(nil)
            self?.panel = nil
        }
    }
}
