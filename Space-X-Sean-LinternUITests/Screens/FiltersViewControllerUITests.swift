import XCTest

class FiltersViewControllerUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUp() {
        continueAfterFailure = true
        app = XCUIApplication()
        super.setUp()
    }
    
    func testViewSuccess() {
        app.launchEnvironment = ["UITests": "filters"]
        app.launch()

        XCTContext.runActivity(named: "Validate elements", block: { _ in
            XCTAssertTrue(app.otherElements["pickerContainer"].firstMatch.exists)
            XCTAssertTrue(app.pickers["yearPicker"].firstMatch.exists)

            let sortedControl = app.segmentedControls["sortedControl"].firstMatch
            XCTAssertTrue(sortedControl.exists)
            let ascendingButton = sortedControl.buttons["Ascending"]
            XCTAssertTrue(ascendingButton.isSelected)

            let successControl = app.segmentedControls["successControl"].firstMatch
            XCTAssertTrue(successControl.exists)
            let noneButton = successControl.buttons["None"]
            XCTAssertTrue(noneButton.isSelected)

            let yearButton = app.buttons["yearValueButton"].firstMatch
            XCTAssertTrue(yearButton.exists)
            XCTAssertEqual(yearButton.label, "None")
        })
    }
    
    func testError() {
        app.launchEnvironment = ["UITests": "filtersExisting"]
        app.launch()

        XCTContext.runActivity(named: "Validate elements", block: { _ in
            let sortedControl = app.segmentedControls["sortedControl"].firstMatch
            XCTAssertTrue(sortedControl.exists)
            let ascendingButton = sortedControl.buttons["Descending"]
            XCTAssertTrue(ascendingButton.isSelected)

            let successControl = app.segmentedControls["successControl"].firstMatch
            XCTAssertTrue(successControl.exists)
            let noneButton = successControl.buttons["Successful"]
            XCTAssertTrue(noneButton.isSelected)

            let yearButton = app.buttons["yearValueButton"].firstMatch
            XCTAssertTrue(yearButton.exists)
            XCTAssertEqual(yearButton.label, "1999")
        })
    }
}
