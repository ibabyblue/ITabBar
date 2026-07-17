//
//  _ILiquidTabInteractionState.swift
//  ITabBar
//
//  Created by ibabyblue on 2026/07/17.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

import Foundation

private let _liquidDoubleTapWindow: TimeInterval = 0.3

struct _ILiquidTabInteractionState<Tab: Hashable> {
    private var lastTab: Tab?
    private var lastTime: Date = .distantPast

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

    private mutating func reset() {
        lastTab = nil
        lastTime = .distantPast
    }
}
