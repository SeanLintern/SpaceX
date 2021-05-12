import XCTest
@testable import Space_X_Sean_Lintern

class AppCoordinatorTests: XCTestCase {
    func testState() {
        XCTAssertEqual(AppCoordinator.state(event: .initial), .willShowLaunches)
    }
    
    func testInvalids() {
        XCTAssertEqual(LaunchesCoordinator.state(event: .willShowLaunches), .invalid)
    }
}
