import Foundation
import XCTest
@testable import Space_X_Sean_Lintern

class LaunchCellViewModelTests: XCTestCase {

    func testEquitable() {
        let sutLaunch = Launch(missionName: "Test",
                               launchYear: "1999",
                               launchDateUtc: "soinfoa",
                               launchSuccess: false,
                               links: Launch.Links(missionPatchSmall: nil,
                                                   articleLink: nil,
                                                   wikipedia: nil,
                                                   videoLink: nil),
                               rocket: Rocket(rocketName: "My Rocket",
                                              rocketType: "Super"))
        let model = LaunchCellViewModel(model: sutLaunch)
        let model2 = LaunchCellViewModel(model: sutLaunch)
        XCTAssertEqual(model, model2)
        
        let nonMatch = Launch(missionName: "Test2",
                               launchYear: "1999",
                               launchDateUtc: "soinfoa",
                               launchSuccess: false,
                               links: Launch.Links(missionPatchSmall: nil,
                                                   articleLink: nil,
                                                   wikipedia: nil,
                                                   videoLink: nil),
                               rocket: Rocket(rocketName: "My Rocket",
                                              rocketType: "Super"))
        let nonMatchingVM = LaunchCellViewModel(model: nonMatch)
        
        XCTAssertNotEqual(nonMatchingVM, model)
    }
    
    func testDaysAt() {
        let sutLaunch = Launch(missionName: "Test",
                               launchYear: "1999",
                               launchDateUtc: "2006-03-24T22:30:00.000Z",
                               launchSuccess: false,
                               links: Launch.Links(missionPatchSmall: nil,
                                                   articleLink: nil,
                                                   wikipedia: nil,
                                                   videoLink: nil),
                               rocket: Rocket(rocketName: "My Rocket",
                                              rocketType: "Super"))
        let model = LaunchCellViewModel(model: sutLaunch)

        XCTAssertEqual(model.launchTime, "Mar 24, 2006 at 10:30 PM")
    }
}
