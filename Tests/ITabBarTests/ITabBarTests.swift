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
        #expect(ITabBarStyle().curveRadius == 28)
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
}
