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
