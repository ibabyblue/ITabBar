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
    @Test func defaultBackgroundColorIsNil() {
        #expect(ITabBarStyle().backgroundColor == nil)
    }

    @Test func defaultFabColorIsBlue() {
        #expect(ITabBarStyle().fabColor == .blue)
    }
}

#if os(iOS) && compiler(>=6.2)
@Suite struct ILiquidTabBarTests {
    @Test @MainActor func liquidTabBarCanBeConstructed() {
        if #available(iOS 26.0, *) {
            var selection = 1
            let binding = Binding(
                get: { selection },
                set: { selection = $0 }
            )

            _ = ILiquidTabBar(
                tabs: [1, 2],
                selection: binding,
                configs: [
                    1: .init(icon: "house", title: "Home"),
                    2: .init(icon: "person", title: "Profile")
                ]
            ) { tab in
                Text("Tab \(tab)")
            }
        }
    }

    @Test func itemConfigRetainsValues() {
        if #available(iOS 26.0, *) {
            let config = ILiquidTabBarItemConfig(
                icon: "house",
                selectedIcon: "house.fill",
                title: "Home",
                badge: "3"
            )

            #expect(config.icon == "house")
            #expect(config.selectedIcon == "house.fill")
            #expect(config.title == "Home")
            #expect(config.badge == "3")
        }
    }

    @Test func minimizeBehaviorMapsToUIKit() {
        if #available(iOS 26.0, *) {
            #expect(ILiquidTabBarMinimizeBehavior.automatic.uiKitValue == .automatic)
            #expect(ILiquidTabBarMinimizeBehavior.never.uiKitValue == .never)
            #expect(ILiquidTabBarMinimizeBehavior.onScrollDown.uiKitValue == .onScrollDown)
            #expect(ILiquidTabBarMinimizeBehavior.onScrollUp.uiKitValue == .onScrollUp)
        }
    }

    @Test func snapshotCorrectsRemovedSelection() {
        if #available(iOS 26.0, *) {
            let snapshot = _ILiquidTabSnapshot(
                tabs: [1, 3],
                configs: [:] as [Int: ILiquidTabBarItemConfig]
            )

            #expect(snapshot.resolvedSelection(2) == 1)
            #expect(snapshot.selectedIndex(for: 2) == 0)
        }
    }

    @Test func snapshotPreservesSelectionAcrossReordering() {
        if #available(iOS 26.0, *) {
            let snapshot = _ILiquidTabSnapshot(
                tabs: [3, 1, 2],
                configs: [:] as [Int: ILiquidTabBarItemConfig]
            )

            #expect(snapshot.resolvedSelection(2) == 2)
            #expect(snapshot.selectedIndex(for: 2) == 2)
        }
    }

    @Test func emptySnapshotHasNoResolvedSelection() {
        if #available(iOS 26.0, *) {
            let snapshot = _ILiquidTabSnapshot(
                tabs: [] as [Int],
                configs: [:] as [Int: ILiquidTabBarItemConfig]
            )

            #expect(snapshot.resolvedSelection(2) == nil)
            #expect(snapshot.selectedIndex(for: 2) == nil)
        }
    }
}
#endif

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
