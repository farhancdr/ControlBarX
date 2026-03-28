import XCTest

final class ControlBarXUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    /// Taps the menu bar item using a coordinate offset (workaround for zero-frame MenuBarExtra).
    private func openPopover() throws {
        let menuBarItem = app.menuBarItems["ControlBarX"]
        guard menuBarItem.waitForExistence(timeout: 5) else {
            XCTFail("Menu bar item not found")
            return
        }
        // Use coordinate tap since MenuBarExtra reports zero frame
        let coordinate = menuBarItem.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        coordinate.tap()
        // Wait for popover to appear
        Thread.sleep(forTimeInterval: 0.5)
    }

    // MARK: - Tests

    func testMenuBarItemExists() throws {
        let menuBarItem = app.menuBarItems["ControlBarX"]
        XCTAssertTrue(menuBarItem.waitForExistence(timeout: 5), "Menu bar item should exist")
    }

    func testPopoverShowsKeyboardRow() throws {
        try openPopover()
        XCTAssertTrue(app.staticTexts["Block Keyboard"].waitForExistence(timeout: 3))
    }

    func testPopoverShowsNetworkRow() throws {
        try openPopover()
        XCTAssertTrue(app.staticTexts["↓"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["↑"].exists)
    }

    func testPopoverShowsSystemRow() throws {
        try openPopover()
        XCTAssertTrue(app.staticTexts["RAM"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["CPU"].exists)
    }

    func testKeyboardBlockerToggleExists() throws {
        try openPopover()
        let toggle = app.switches.firstMatch
        XCTAssertTrue(toggle.waitForExistence(timeout: 3), "Keyboard blocker toggle should exist")
    }

    func testQuitButtonExists() throws {
        try openPopover()
        XCTAssertTrue(app.staticTexts["Quit"].waitForExistence(timeout: 3), "Quit button should exist")
    }
}
