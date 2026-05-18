import SwiftUI

// Window for detecting the second tap in a double-tap, matching UIKit's default tapCount window.
private let _doubleTapWindow: TimeInterval = 0.3

@MainActor
struct _TabBarItem<TabItemView: View & Sendable>: View {
    let isSelected: Bool
    let animation: ITabBarAnimation
    let onTap: () -> Void
    let onDoubleTap: (() -> Void)?
    let onLongPress: (() -> Void)?
    @ViewBuilder let content: () -> TabItemView

    @State private var animKey = false
    @State private var lastTapTime: Date = .distantPast

    // Mirrors UIKit's `touchDown` + `touchDownRepeat` split: single tap fires immediately
    // on the first touch, and a second touch within the window fires the double-tap handler
    // (without re-firing single). Long press cancels any pending double-tap timing.
    var body: some View {
        animatedContent
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .gesture(
                LongPressGesture(minimumDuration: 0.5)
                    .onEnded { _ in
                        lastTapTime = .distantPast
                        onLongPress?()
                    }
                    .exclusively(before:
                        TapGesture(count: 1).onEnded {
                            let now = Date()
                            if let onDoubleTap, now.timeIntervalSince(lastTapTime) < _doubleTapWindow {
                                lastTapTime = .distantPast
                                onDoubleTap()
                            } else {
                                lastTapTime = now
                                onTap()
                                if isSelected { animKey.toggle() }
                            }
                        }
                    )
            )
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
            builder(ITabBarAnimationContext(isSelected: isSelected, tapTrigger: animKey))
        }
    }
}
