import XCTest

@MainActor
final class ITabBarDemoUITests: XCTestCase {
    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        return app
    }

    func testCatalogShowsStandardExamples() {
        let app = launchApp()

        let examples = [
            "basicPlain", "tapInteractions", "concaveFAB", "convexFAB",
            "dynamicTabs", "customStyling", "customTabItem",
            "builtInAnimations", "lottieAnimation", "nativeLiquidGlass",
        ]
        for example in examples {
            let row = app.buttons["demo.example.\(example)"]
            if !row.exists {
                app.swipeUp()
            }
            XCTAssertTrue(row.waitForExistence(timeout: 2), example)
        }
    }

    func testBasicPlainChangesSelectionAndShowsBadge() {
        let app = launchApp()

        openExample("basicPlain", in: app)
        XCTAssertTrue(app.staticTexts["3"].waitForExistence(timeout: 2))
        app.staticTexts["Explore"].tap()
        XCTAssertEqual(statusValue(DemoID.basicSelection, in: app), "Explore")
        capture("Basic Plain", app: app)
    }

    func testTapInteractionsReportDoubleTapAndLongPress() {
        let app = launchApp()

        openExample("tapInteractions", in: app)
        app.staticTexts["Search"].doubleTap()
        XCTAssertEqual(statusValue(DemoID.tapDoubleCount, in: app), "1")
        app.staticTexts["Profile"].press(forDuration: 0.7)
        XCTAssertEqual(statusValue(DemoID.tapLongPressCount, in: app), "0")
        app.staticTexts
            .matching(NSPredicate(format: "label == %@", "Search"))
            .element(boundBy: 1)
            .press(forDuration: 0.7)
        XCTAssertEqual(statusValue(DemoID.tapLongPressCount, in: app), "1")
    }

    func testConcaveAndConvexCenterButtonsReportTaps() {
        let app = launchApp()

        openExample("concaveFAB", in: app)
        app.buttons["Add"].tap()
        XCTAssertEqual(statusValue(DemoID.concaveFABCount, in: app), "1")
        capture("Concave FAB", app: app)

        app.navigationBars.buttons.element(boundBy: 0).tap()
        openExample("convexFAB", in: app)
        app.buttons["Add"].tap()
        XCTAssertEqual(statusValue(DemoID.convexFABCount, in: app), "1")
        capture("Convex FAB", app: app)
    }

    func testCustomStylingAndCustomItemExamplesAreInteractive() {
        let app = launchApp()

        openExample("customStyling", in: app)
        XCTAssertTrue(app.navigationBars["Custom Styling"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["9"].exists)

        app.navigationBars.buttons.element(boundBy: 0).tap()
        openExample("customTabItem", in: app)
        app.staticTexts["Library"].tap()
        XCTAssertEqual(statusValue(DemoID.customItemSelection, in: app), "Library")
        capture("Custom Tab Item", app: app)
    }

    func testAnimationExamplesOpenAndChangeTabs() {
        let app = launchApp()

        openExample("builtInAnimations", in: app)
        app.staticTexts["Wiggle"].tap()
        XCTAssertTrue(app.navigationBars["Built-in Animations"].exists)

        app.navigationBars.buttons.element(boundBy: 0).tap()
        openExample("lottieAnimation", in: app)
        for title in ["Fruit", "Switch", "Icons", "Heart"] {
            app.staticTexts[title].firstMatch.tap()
            Thread.sleep(forTimeInterval: 1.5)
            capture("Lottie \(title)", app: app)
            for tabTitle in ["Heart", "Fruit", "Switch", "Icons"] {
                let expectedCount = tabTitle == title ? 2 : 1
                XCTAssertEqual(
                    app.staticTexts.matching(NSPredicate(format: "label == %@", tabTitle)).count,
                    expectedCount,
                    "\(tabTitle) should remain visible while \(title) is animating"
                )
            }
        }
        XCTAssertTrue(app.navigationBars["Lottie Animation"].exists)
    }

    func testDynamicTabsCorrectSelectionAfterRemovingSelectedTab() {
        let app = launchApp()

        openExample("dynamicTabs", in: app)
        app.staticTexts["Profile"].tap()
        app.buttons["Remove selected tab"].tap()
        XCTAssertTrue(waitForStatus(DemoID.dynamicSelection, toEqual: "Home", in: app))
        app.buttons["Add Favorites tab"].tap()
        XCTAssertTrue(statusValue(DemoID.dynamicOrder, in: app).contains("Favorites"))
        capture("Dynamic Tabs", app: app)
    }

    func testNativeLiquidGlassUpdatesSelectionAndTabs() throws {
        guard #available(iOS 26.0, *) else {
            throw XCTSkip("ILiquidTabBar is available on iOS 26 or newer.")
        }

        let app = launchApp()
        openExample("nativeLiquidGlass", in: app)

        app.tabBars.buttons["Activity"].doubleTap()
        XCTAssertEqual(statusValue(DemoID.liquidDoubleCount, in: app), "1")
        XCTAssertTrue(waitForStatus(DemoID.liquidSelection, toEqual: "Activity", in: app))

        app.buttons["Select next tab"].tap()
        XCTAssertTrue(waitForStatus(DemoID.liquidSelection, toEqual: "Profile", in: app))
        app.buttons["Remove selected tab"].tap()
        XCTAssertTrue(waitForStatus(DemoID.liquidSelection, toEqual: "Home", in: app))
        XCTAssertFalse(statusValue(DemoID.liquidOrder, in: app).contains("Profile"))
        capture("Native Liquid Glass", app: app)
    }

    private func statusValue(_ identifier: String, in app: XCUIApplication) -> String {
        let element = app.staticTexts[identifier]
        XCTAssertTrue(element.waitForExistence(timeout: 2), identifier)
        return element.label
    }

    private func openExample(_ name: String, in app: XCUIApplication) {
        let row = app.buttons["demo.example.\(name)"]
        for _ in 0..<8 {
            if row.exists && row.isHittable {
                row.tap()
                return
            }
            app.swipeUp()
        }
        XCTFail("Could not open demo example: \(name)")
    }

    private func waitForStatus(
        _ identifier: String,
        toEqual expectedValue: String,
        in app: XCUIApplication
    ) -> Bool {
        let element = app.staticTexts[identifier]
        guard element.waitForExistence(timeout: 2) else { return false }
        let predicate = NSPredicate(format: "label == %@", expectedValue)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        return XCTWaiter.wait(for: [expectation], timeout: 2) == .completed
    }

    private func capture(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

private enum DemoID {
    static let basicSelection = "demo.basic.selection"
    static let tapDoubleCount = "demo.tap.doubleCount"
    static let tapLongPressCount = "demo.tap.longPressCount"
    static let concaveFABCount = "demo.concave.fabCount"
    static let convexFABCount = "demo.convex.fabCount"
    static let customItemSelection = "demo.customItem.selection"
    static let dynamicSelection = "demo.dynamic.selection"
    static let dynamicOrder = "demo.dynamic.order"
    static let liquidSelection = "demo.liquid.selection"
    static let liquidOrder = "demo.liquid.order"
    static let liquidDoubleCount = "demo.liquid.doubleCount"
}
