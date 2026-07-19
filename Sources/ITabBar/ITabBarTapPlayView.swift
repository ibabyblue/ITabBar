//
//  ITabBarTapPlayView.swift
//  ITabBar
//
//  Created by ibabyblue on 2026/05/18.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

import SwiftUI

/// A drop-in container for `ITabBarItemConfig.animation = .custom { ... }` that toggles
/// between a default (resting) view and an active (playback) view in response to taps.
///
/// Behavior:
///   - Shows `defaultView` initially and whenever no playback is in flight.
///   - On every tap on this tab — including re-taps of the currently-selected tab — the
///     `activeView` is mounted and remains visible for `duration` seconds before snapping
///     back to `defaultView`.
///   - Re-tap during an in-flight playback restarts the active view from scratch by
///     flipping its SwiftUI identity (`.id(context.tapTrigger)`), so any internal animation
///     replays from frame 0.
///   - Switching to a different tab immediately tears down the active view and reverts
///     to `defaultView`.
///
/// Usage:
/// ```swift
/// animation: .custom { ctx in
///     AnyView(
///         ITabBarTapPlayView(context: ctx, duration: 1.5) {
///             Image(systemName: "heart")
///         } active: {
///             LottieView(animation: .named("heart"))
///                 .resizable()
///                 .playbackMode(.playing(.fromProgress(0, toProgress: 1, loopMode: .playOnce)))
///         }
///     )
/// }
/// ```
@MainActor
public struct ITabBarTapPlayView<Default: View, Active: View>: View {
    /// The current selection and replay state supplied by the tab bar.
    private let context: ITabBarAnimationContext
    /// The requested active-content lifetime, in seconds.
    private let duration: TimeInterval
    /// A builder for the resting item content.
    private let defaultView: () -> Default
    /// A builder for the playback item content.
    private let activeView: () -> Active

    /// Whether the active content is currently mounted.
    @State private var isActive = false
    /// The pending task that restores the resting content after playback.
    @State private var resetTask: Task<Void, Never>?

    /// Creates a container that swaps resting content for playback content on each tap.
    ///
    /// A nonpositive duration still allows the active view to mount briefly. The container adds
    /// a small grace interval before restoring the resting view so one-shot animations can render
    /// their final frame.
    ///
    /// - Parameters:
    ///   - context: The custom-animation context supplied by ``ITabBar``.
    ///   - duration: The intended playback duration, in seconds.
    ///   - defaultView: The content shown while no playback is active.
    ///   - activeView: The content mounted while playback is active.
    public init(
        context: ITabBarAnimationContext,
        duration: TimeInterval,
        @ViewBuilder defaultView: @escaping () -> Default,
        @ViewBuilder active activeView: @escaping () -> Active
    ) {
        self.context = context
        self.duration = duration
        self.defaultView = defaultView
        self.activeView = activeView
    }

    /// The resting or active content for the current playback state.
    public var body: some View {
        ZStack {
            if isActive {
                activeView()
                    // tapTrigger flips on every tap → .id changes → activeView is rebuilt
                    // from scratch, which restarts any internal animation from the beginning.
                    .id(context.tapTrigger)
            } else {
                defaultView()
            }
        }
        .onChange(of: context.tapTrigger) { _, _ in startPlayback() }
        .onChange(of: context.isSelected) { _, isNowSelected in
            if !isNowSelected {
                resetTask?.cancel()
                isActive = false
            }
        }
    }

    /// Restarts playback and schedules restoration of the resting content.
    private func startPlayback() {
        resetTask?.cancel()
        isActive = true
        let durationNs = UInt64(max(0, (duration + 0.05) * 1_000_000_000))
        resetTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: durationNs)
            if !Task.isCancelled {
                isActive = false
            }
        }
    }
}
