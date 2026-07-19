import XCTest

@MainActor
/// End-to-end coverage for the runnable ITabBar example catalog.
final class ITabBarDemoUITests: XCTestCase {
    /// Launches a fresh example application instance.
    ///
    /// - Returns: The launched application proxy.
    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        return app
    }

    /// Verifies that every supported integration scenario appears in the catalog.
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

    /// Verifies plain-bar selection and badge presentation.
    func testBasicPlainChangesSelectionAndShowsBadge() {
        let app = launchApp()

        openExample("basicPlain", in: app)
        XCTAssertTrue(app.staticTexts["3"].waitForExistence(timeout: 2))
        app.staticTexts["Explore"].tap()
        XCTAssertEqual(statusValue(DemoID.basicSelection, in: app), "Explore")
        capture("Basic Plain", app: app)
    }

    /// Verifies same-tab double taps and selected-only long presses.
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

    /// Verifies both curved center buttons dispatch their actions.
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

    /// Verifies custom styling and custom item scenes remain interactive.
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

    /// Verifies built-in and bundled Lottie animation scenes open and change tabs.
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

    /// Verifies removal of the selected dynamic tab corrects selection and preserves insertion.
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

    /// Verifies native iOS 26 selection, double taps, tab removal, and correction.
    ///
    /// - Throws: An `XCTSkip` error when the test runtime predates iOS 26.
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

    /// Reads an observable demo status value by accessibility identifier.
    ///
    /// - Parameters:
    ///   - identifier: The status value's accessibility identifier.
    ///   - app: The running example application.
    /// - Returns: The status element's accessibility label.
    private func statusValue(_ identifier: String, in app: XCUIApplication) -> String {
        let element = app.staticTexts[identifier]
        XCTAssertTrue(element.waitForExistence(timeout: 2), identifier)
        return element.label
    }

    /// Scrolls the catalog until the named example is hittable, then opens it.
    ///
    /// - Parameters:
    ///   - name: The raw ``DemoExample`` name embedded in the row identifier.
    ///   - app: The running example application.
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

    /// Waits for an observable demo status to match an expected value.
    ///
    /// - Parameters:
    ///   - identifier: The status value's accessibility identifier.
    ///   - expectedValue: The exact accessibility label expected from the value.
    ///   - app: The running example application.
    /// - Returns: `true` when the value matches before the timeout.
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

    /// Attaches a named screenshot to the current test result.
    ///
    /// - Parameters:
    ///   - name: The attachment's descriptive name.
    ///   - app: The running application to capture.
    private func capture(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

/// Accessibility identifiers mirrored from the application target for UI-test lookup.
private enum DemoID {
    /// The selected value in the basic plain example.
    static let basicSelection = "demo.basic.selection"
    /// The double-tap count in the interaction example.
    static let tapDoubleCount = "demo.tap.doubleCount"
    /// The long-press count in the interaction example.
    static let tapLongPressCount = "demo.tap.longPressCount"
    /// The center-button tap count in the concave example.
    static let concaveFABCount = "demo.concave.fabCount"
    /// The center-button tap count in the convex example.
    static let convexFABCount = "demo.convex.fabCount"
    /// The selected value in the custom-item example.
    static let customItemSelection = "demo.customItem.selection"
    /// The selected value in the dynamic-tabs example.
    static let dynamicSelection = "demo.dynamic.selection"
    /// The ordered values in the dynamic-tabs example.
    static let dynamicOrder = "demo.dynamic.order"
    /// The selected value in the native liquid example.
    static let liquidSelection = "demo.liquid.selection"
    /// The ordered values in the native liquid example.
    static let liquidOrder = "demo.liquid.order"
    /// The double-tap count in the native liquid example.
    static let liquidDoubleCount = "demo.liquid.doubleCount"
}
