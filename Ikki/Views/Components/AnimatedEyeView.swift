import SwiftUI

struct AnimatedEyeView: View {
    var isOpen: Bool
    var color: Color = AppColors.eyeRing

    var body: some View {
        ZStack {
            Image(systemName: isOpen ? "eye.fill" : "eye.slash.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 80)
                .foregroundStyle(color)
                .contentTransition(.symbolEffect(.replace))
        }
        .animation(AppAnimations.snappy, value: isOpen)
    }
}
