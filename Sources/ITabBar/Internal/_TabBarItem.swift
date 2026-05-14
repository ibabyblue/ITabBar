import SwiftUI

@MainActor
struct _TabBarItem<TabItemView: View & Sendable>: View {
    let isSelected: Bool
    let animation: ITabBarAnimation
    let onTap: () -> Void
    let onDoubleTap: (() -> Void)?
    let onLongPress: (() -> Void)?
    @ViewBuilder let content: () -> TabItemView

    @State private var animKey = false

    var body: some View {
        animatedContent
            .contentShape(Rectangle())
            .gesture(
                TapGesture(count: 2)
                    .onEnded { onDoubleTap?() }
                    .exclusively(before: TapGesture(count: 1)
                        .onEnded {
                            onTap()
                            if isSelected { animKey.toggle() }
                        }
                    )
            )
            .onLongPressGesture(minimumDuration: 0.5) {
                onLongPress?()
            }
            .onChange(of: isSelected) { _, newValue in
                if newValue { animKey.toggle() }
            }
    }

    @ViewBuilder
    private var animatedContent: some View {
        switch animation {
        case .bounce:
            content()
                .keyframeAnimator(initialValue: CGFloat(1.0), trigger: animKey) { view, scale in
                    view.scaleEffect(scale)
                } keyframes: { _ in
                    KeyframeTrack {
                        SpringKeyframe(1.25, duration: 0.15, spring: .bouncy)
                        SpringKeyframe(1.0,  duration: 0.2,  spring: .smooth)
                    }
                }
        case .wiggle:
            content()
                .keyframeAnimator(initialValue: CGFloat(0), trigger: animKey) { view, angle in
                    view.rotationEffect(.degrees(angle))
                } keyframes: { _ in
                    KeyframeTrack {
                        CubicKeyframe(-15.0, duration: 0.07)
                        CubicKeyframe( 15.0, duration: 0.14)
                        CubicKeyframe(  0.0, duration: 0.07)
                    }
                }
        case .pop:
            content()
                .keyframeAnimator(initialValue: CGFloat(1.0), trigger: animKey) { view, scale in
                    view.scaleEffect(scale)
                } keyframes: { _ in
                    KeyframeTrack {
                        SpringKeyframe(1.4, duration: 0.1,  spring: .bouncy(duration: 0.1, extraBounce: 0.2))
                        SpringKeyframe(1.0, duration: 0.25, spring: .smooth)
                    }
                }
        case .none:
            content()
        case .custom(let builder):
            builder(isSelected)
        }
    }
}
