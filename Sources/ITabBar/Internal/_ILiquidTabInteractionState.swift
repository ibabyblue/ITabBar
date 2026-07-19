//
//  _ILiquidTabInteractionState.swift
//  ITabBar
//
//  Created by ibabyblue on 2026/07/17.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

import Foundation

/// The maximum interval, in seconds, between native selections recognized as a double tap.
private let _liquidDoubleTapWindow: TimeInterval = 0.3

/// Same-tab selection timing for the native liquid tab bar.
struct _ILiquidTabInteractionState<Tab: Hashable> {
    /// The identifier selected most recently while recognition was enabled.
    private var lastTab: Tab?
    /// The timestamp associated with ``lastTab``.
    private var lastTime: Date = .distantPast

    /// Registers a native tab selection and recognizes a same-tab double selection.
    ///
    /// - Parameters:
    ///   - tab: The newly selected tab identifier.
    ///   - now: The selection timestamp.
    ///   - enabled: Whether a double-tap callback is installed.
    /// - Returns: `true` when the same tab was selected twice inside the recognition window.
    mutating func registerSelection(
        _ tab: Tab,
        at now: Date,
        enabled: Bool
    ) -> Bool {
        guard enabled else {
            reset()
            return false
        }

        if lastTab == tab, now.timeIntervalSince(lastTime) < _liquidDoubleTapWindow {
            reset()
            return true
        }

        lastTab = tab
        lastTime = now
        return false
    }

    /// Clears the pending first selection and timestamp.
    private mutating func reset() {
        lastTab = nil
        lastTime = .distantPast
    }
}
