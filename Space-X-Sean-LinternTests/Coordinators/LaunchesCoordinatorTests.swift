import XCTest
@testable import Space_X_Sean_Lintern

class LaunchesCoordinatorTests: XCTestCase {
    func testState() {
        XCTAssertEqual(LaunchesCoordinator.state(event: .initial), .willShowLaunches)
        
        let testURL = URL(string: "https://google.com")!
        XCTAssertEqual(LaunchesCoordinator.state(event: .didSelectLaunchArticle(testURL)), .willShowWebpage(testURL))
        
        XCTAssertEqual(LaunchesCoordinator.state(event: .didSelectShowFilters(existing: nil, years: [], callBack: { _ in })),
                       .willShowFilters(existing: nil, years: [], callBack: { _ in}))
    }
    
    func testInvalids() {
        XCTAssertEqual(LaunchesCoordinator.state(event: .willShowLaunches), .invalid)
    }
}
