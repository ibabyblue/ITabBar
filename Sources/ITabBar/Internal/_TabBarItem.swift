//
//  _TabBarItem.swift
//  ITabBar
//
//  Created by ibabyblue on 2026/05/14.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

import SwiftUI

/// The maximum interval, in seconds, between taps recognized as a double tap.
private let _doubleTapWindow: TimeInterval = 0.3

/// The interaction outcome produced after registering a standard tab tap.
enum _TabTapAction: Equatable {
    /// The tap should perform the normal selection action.
    case single
    /// The tap completes a same-tab double-tap sequence.
    case double
}

/// Interaction timing and animation-replay state for one standard tab item.
struct _TabInteractionState {
    /// A token flipped whenever the item animation should replay.
    private(set) var animationTrigger = false
    /// The first tap time retained while waiting for a possible second tap.
    private var lastTapTime: Date = .distantPast

    /// Registers a tap and resolves whether it is a single or double interaction.
    ///
    /// A selected item's single tap replays its animation. When double-tap handling is enabled,
    /// a second tap inside the recognition window returns ``_TabTapAction/double`` and also
    /// replays the animation.
    ///
    /// - Parameters:
    ///   - now: The timestamp associated with the tap.
    ///   - isSelected: Whether the item was selected when tapped.
    ///   - doubleTapEnabled: Whether a double-tap callback is installed.
    /// - Returns: The action that the view should dispatch.
    mutating func registerTap(
        at now: Date,
        isSelected: Bool,
        doubleTapEnabled: Bool
    ) -> _TabTapAction {
        if doubleTapEnabled, now.timeIntervalSince(lastTapTime) < _doubleTapWindow {
            lastTapTime = .distantPast
            animationTrigger.toggle()
            return .double
        }

        lastTapTime = now
        if isSelected {
            animationTrigger.toggle()
        }
        return .single
    }

    /// Marks the item as newly selected and requests an animation replay.
    mutating func becameSelected() {
        animationTrigger.toggle()
    }

    /// Registers a long press and clears pending double-tap timing.
    ///
    /// - Parameter isSelected: Whether the pressed item is currently selected.
    /// - Returns: `true` only when the long-pressed item is selected.
    mutating func registerLongPress(isSelected: Bool) -> Bool {
        lastTapTime = .distantPast
        return isSelected
    }
}

@MainActor
/// A standard tab item's gesture recognition and animation container.
struct _TabBarItem<TabItemView: View & Sendable>: View {
    /// Whether this item currently represents the selected tab.
    let isSelected: Bool
    /// The built-in or custom animation applied to the content.
    let animation: ITabBarAnimation
    /// The action that selects this tab after a single tap.
    let onTap: () -> Void
    /// The optional action dispatched after a same-tab double tap.
    let onDoubleTap: (() -> Void)?
    /// The optional action dispatched after a long press on a selected item.
    let onLongPress: (() -> Void)?
    /// The item content builder supplied by the public tab bar.
    @ViewBuilder let content: () -> TabItemView

    /// Persistent timing and animation state for the rendered item.
    @State private var interactionState = _TabInteractionState()

    // Mirrors UIKit's `touchDown` + `touchDownRepeat` split: single tap fires immediately
    // on the first touch, and a second touch within the window fires the double-tap handler
    // (without re-firing single). Long press cancels any pending double-tap timing.
    /// The animated item content with mutually exclusive long-press and tap gestures.
    var body: some View {
        animatedContent
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .gesture(
                LongPressGesture(minimumDuration: 0.5)
                    .onEnded { _ in
                        if interactionState.registerLongPress(isSelected: isSelected) {
                            onLongPress?()
                        }
                    }
                    .exclusively(before:
                        TapGesture(count: 1).onEnded {
                            let action = interactionState.registerTap(
                                at: Date(),
                                isSelected: isSelected,
                                doubleTapEnabled: onDoubleTap != nil
                            )
                            switch action {
                            case .single:
                                onTap()
                            case .double:
                                onDoubleTap?()
                            }
                        }
                    )
            )
            .onChange(of: isSelected) { _, newValue in
                if newValue { interactionState.becameSelected() }
            }
    }

    @ViewBuilder
    /// The item content wrapped in the selected built-in animation or custom builder.
    private var animatedContent: some View {
        switch animation {
        case .bounce:
            content()
                .keyframeAnimator(initialValue: CGFloat(1.0), trigger: interactionState.animationTrigger) { view, scale in
                    view.scaleEffect(scale)
                } keyframes: { _ in
                    KeyframeTrack {
                        SpringKeyframe(1.25, duration: 0.15, spring: .bouncy)
                        SpringKeyframe(1.0,  duration: 0.2,  spring: .smooth)
                    }
                }
        case .wiggle:
            content()
                .keyframeAnimator(initialValue: CGFloat(0), trigger: interactionState.animationTrigger) { view, angle in
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
                .keyframeAnimator(initialValue: CGFloat(1.0), trigger: interactionState.animationTrigger) { view, scale in
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
            builder(ITabBarAnimationContext(
                isSelected: isSelected,
                tapTrigger: interactionState.animationTrigger
            ))
        }
    }
}
