//
//  ITabBarTests.swift
//  ITabBarTests
//
//  Created by ibabyblue on 2026/05/14.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

import Testing
import SwiftUI
@testable import ITabBar

@Suite struct ITabBarStyleTests {
    @Test func defaultHeight() {
        #expect(ITabBarStyle().height == 56)
    }
    @Test func defaultFabSize() {
        #expect(ITabBarStyle().fabSize == 52)
    }
    @Test func defaultCurveRadius() {
        #expect(ITabBarStyle().curveRadius == 38)
    }
    @Test func defaultItemSpacingIsZero() {
        #expect(ITabBarStyle().itemSpacing == 0)
    }
    @Test func liquidGlassDefaultFalse() {
        #expect(ITabBarStyle().useLiquidGlass == false)
    }
}

@Suite struct ITabBarItemConfigTests {
    @Test func badgeTruncatesAt3() {
        #expect(badgeTruncated("1234") == "123")
    }
    @Test func badgeShortPassesThrough() {
        #expect(badgeTruncated("99") == "99")
    }
    @Test func badgeNilPassesNil() {
        #expect(badgeTruncated(nil) == nil)
    }
}

@Suite struct SelectionHelpersTests {
    @Test func validSelectionReturnsItself() {
        #expect(validatedSelection(2, in: [1, 2, 3]) == 2)
    }
    @Test func invalidSelectionReturnsFirst() {
        #expect(validatedSelection(99, in: [1, 2, 3]) == 1)
    }
    @Test func emptyTabsReturnsNil() {
        #expect(validatedSelection(1, in: [] as [Int]) == nil)
    }
    @Test func singleTabAlwaysReturnsIt() {
        #expect(validatedSelection(42, in: [7]) == 7)
    }

    @Test func validSelectionNeedsNoCorrection() {
        #expect(selectionCorrection(2, in: [1, 2, 3]) == nil)
    }

    @Test func invalidSelectionCorrectsToFirstTab() {
        #expect(selectionCorrection(99, in: [1, 2, 3]) == 1)
    }

    @Test func emptyTabsNeedsNoCorrection() {
        #expect(selectionCorrection(1, in: [] as [Int]) == nil)
    }
}

@Suite struct TabInteractionStateTests {
    private let start = Date(timeIntervalSinceReferenceDate: 1_000)

    @Test func selectingTabTriggersAnimationOnce() {
        var state = _TabInteractionState()

        #expect(state.registerTap(at: start, isSelected: false, doubleTapEnabled: true) == .single)
        #expect(state.animationTrigger == false)

        state.becameSelected()
        #expect(state.animationTrigger == true)
    }

    @Test func retappingSelectedTabTriggersAnimation() {
        var state = _TabInteractionState()

        #expect(state.registerTap(at: start, isSelected: true, doubleTapEnabled: false) == .single)
        #expect(state.animationTrigger == true)
    }

    @Test func secondTapTriggersAnimationAndReturnsDoubleTap() {
        var state = _TabInteractionState()
        _ = state.registerTap(at: start, isSelected: true, doubleTapEnabled: true)

        #expect(
            state.registerTap(
                at: start.addingTimeInterval(0.2),
                isSelected: true,
                doubleTapEnabled: true
            ) == .double
        )
        #expect(state.animationTrigger == false)
    }

    @Test func longPressResetsDoubleTapWindow() {
        var state = _TabInteractionState()
        _ = state.registerTap(at: start, isSelected: true, doubleTapEnabled: true)

        state.registerLongPress()

        #expect(
            state.registerTap(
                at: start.addingTimeInterval(0.2),
                isSelected: true,
                doubleTapEnabled: true
            ) == .single
        )
    }
}

@Suite struct TabBarLayoutMetricsTests {
    @Test func bottomInsetExtendsBackgroundWithoutChangingItemHeight() {
        let metrics = _TabBarLayoutMetrics(itemHeight: 64, bottomInset: 34)

        #expect(metrics.itemHeight == 64)
        #expect(metrics.totalHeight == 98)
    }

    @Test func zeroBottomInsetAddsNoReservedArea() {
        let metrics = _TabBarLayoutMetrics(itemHeight: 56, bottomInset: 0)

        #expect(metrics.itemHeight == 56)
        #expect(metrics.totalHeight == 56)
    }
}
