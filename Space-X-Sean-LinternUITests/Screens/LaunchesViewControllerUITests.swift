import XCTest

class LaunchesViewControllerUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUp() {
        continueAfterFailure = true
        app = XCUIApplication()
        super.setUp()
    }
    
    func testViewSuccess() {
        app.launchEnvironment = ["UITests": "launches"]
        app.launch()

        XCTContext.runActivity(named: "Validate elements", block: { _ in
            XCTAssertTrue(app.cells["section.0.row.0"].firstMatch.exists)
            XCTAssertTrue(app.cells["section.1.row.0"].firstMatch.exists)
            XCTAssertTrue(app.buttons["filterButton"].firstMatch.exists)
        })
    }
    
    func testError() {
        app.launchEnvironment = ["UITests": "launchesError"]
        app.launch()

        XCTContext.runActivity(named: "Validate elements", block: { _ in
            XCTAssertTrue(app.staticTexts["errorLabel"].firstMatch.exists)
        })
    }
}
