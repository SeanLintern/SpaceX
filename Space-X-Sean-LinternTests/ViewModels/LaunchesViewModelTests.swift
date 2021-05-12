import Foundation
import XCTest
@testable import Space_X_Sean_Lintern

class LaunchesViewModelTests: XCTestCase {
    func testLoading() {
        let launchRepository = LaunchesNetwork(network: MockNetwork(jsonMaps: ["launches": "allLaunches", "info": "company"],
                                                                    mockedError: nil))
        let sut = LaunchesViewModel(network: launchRepository) { _ in }
        
        var loadingEvents = [Bool]()
        
        let expectation = XCTestExpectation(description: "Waiting for Parsing")

        sut.outputs.loadingHandler = {
            loadingEvents.append($0)
        }

        sut.outputs.tableDataHandler = { _ in
            expectation.fulfill()
            XCTAssertEqual(loadingEvents, [true, false])
        }
        
        sut.inputs.viewDidLoad()
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testFlows() {
        let launchRepository = LaunchesNetwork(network: MockNetwork(jsonMaps: ["launches": "allLaunches", "info": "company"],
                                                                    mockedError: nil))
        
        var flowEvents = [LaunchesViewModel.Events]()

        let sut = LaunchesViewModel(network: launchRepository) { flowEvents.append($0) }

        sut.inputs.filtersPress()
        
        XCTAssertEqual(flowEvents, [])

        sut.inputs.viewDidLoad()

        let expectation = XCTestExpectation(description: "Waiting for Parsing")
        
        sut.outputs.tableDataHandler = { _ in
            expectation.fulfill()
            
            sut.inputs.filtersPress()

            let parsedYears = ["2020", "2019", "2018", "2017", "2016", "2015", "2014", "2013", "2012", "2010", "2009", "2008", "2007", "2006"]
            
            XCTAssertEqual(flowEvents, [.showFilters(existing: nil, years: parsedYears, callBack: { _ in})])
            
            let testURL = URL(string: "https://google.com")!

            sut.inputs.showDetails(url: testURL)
            
            XCTAssertEqual(flowEvents, [.showFilters(existing: nil, years: parsedYears, callBack: { _ in}), .showURL(testURL)])
        }
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testError() {
        let launchRepository = LaunchesNetwork(network: MockNetwork(jsonMaps: [:],
                                                                    mockedError: nil))
        
        var flowEvents = [LaunchesViewModel.Events]()

        let sut = LaunchesViewModel(network: launchRepository) { flowEvents.append($0) }
        
        let expectation = XCTestExpectation(description: "Waiting for error")

        sut.outputs.errorHandler = {
            XCTAssertEqual($0, "Oh no!\nan error occurred\nPlease pull to refresh\nto try again")
            expectation.fulfill()
        }
        
        sut.inputs.viewDidLoad()
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testListModel() {
        let launchRepository = LaunchesNetwork(network: MockNetwork(jsonMaps: ["launches": "allLaunches", "info": "company"],
                                                                    mockedError: nil))
        let sut = LaunchesViewModel(network: launchRepository) { _ in }
                
        let expectation = XCTestExpectation(description: "Waiting for Model")

        sut.outputs.tableDataHandler = { model in
            expectation.fulfill()

            XCTAssertEqual(model[0].title, "Company")
            XCTAssertEqual((model[0].data.first as? CompanyCellViewModelType)?.text, "SpaceX was founded by Elon Musk in 2002. It has now 7,000 employees, 3 launch sites, and is valued at USD $27,500,000,000")
            
            XCTAssertEqual(model[1].title, "Launches")
            XCTAssertEqual((model[1].data.first as? LaunchCellViewModelType)?.launchTime, "Mar 24, 2006 at 10:30 PM")
            XCTAssertEqual((model[1].data.first as? LaunchCellViewModelType)?.missionName, "FalconSat")
            XCTAssertEqual((model[1].data.first as? LaunchCellViewModelType)?.articleLink, URL(string: "https://www.space.com/2196-spacex-inaugural-falcon-1-rocket-lost-launch.html")!)
            XCTAssertEqual((model[1].data.first as? LaunchCellViewModelType)?.launchSuccessString, "❌")
            XCTAssertEqual((model[1].data.first as? LaunchCellViewModelType)?.patchImageURL, URL(string: "https://images2.imgbox.com/3c/0e/T8iJcSN3_o.png")!)
            XCTAssertEqual((model[1].data.first as? LaunchCellViewModelType)?.videoLink, URL(string: "https://www.youtube.com/watch?v=0a_00nJ_Y88")!)
            XCTAssertEqual((model[1].data.first as? LaunchCellViewModelType)?.wikipedia, URL(string: "https://en.wikipedia.org/wiki/DemoSat")!)
        }
        
        sut.inputs.viewDidLoad()
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testStaticText() {
        let launchRepository = LaunchesNetwork(network: MockNetwork(jsonMaps: ["launches": "allLaunches", "info": "company"],
                                                                    mockedError: nil))
        let sut = LaunchesViewModel(network: launchRepository) { _ in }

        XCTAssertEqual(sut.outputs.title, "SpaceX")
    }
    
    func testFilters() {
        let filters = FilterModel(launchYear: 2010, landingSuccess: true, isAscending: false)
        
        let launchRepository = LaunchesNetwork(network: MockNetwork(jsonMaps: ["launches": "allLaunches", "info": "company"],
                                                                    mockedError: nil))
        
        let sut = LaunchesViewModel(network: launchRepository) { event in
            if case let .showFilters(_, _, callback) = event {
                callback(filters)
            }
        }
                
        let expectation = XCTestExpectation(description: "Waiting for Model")
        expectation.expectedFulfillmentCount = 2

        sut.outputs.tableDataHandler = { model in
            expectation.fulfill()

            XCTAssertEqual(model[0].title, "Company")
            XCTAssertEqual((model[0].data.first as? CompanyCellViewModelType)?.text, "SpaceX was founded by Elon Musk in 2002. It has now 7,000 employees, 3 launch sites, and is valued at USD $27,500,000,000")
            
            XCTAssertEqual(model[1].title, "Launches")
            XCTAssertEqual((model[1].data.first as? LaunchCellViewModelType)?.launchTime, "Mar 24, 2006 at 10:30 PM")
            XCTAssertEqual((model[1].data.first as? LaunchCellViewModelType)?.missionName, "FalconSat")
            XCTAssertEqual((model[1].data.first as? LaunchCellViewModelType)?.articleLink, URL(string: "https://www.space.com/2196-spacex-inaugural-falcon-1-rocket-lost-launch.html")!)
            XCTAssertEqual((model[1].data.first as? LaunchCellViewModelType)?.launchSuccessString, "❌")
            XCTAssertEqual((model[1].data.first as? LaunchCellViewModelType)?.patchImageURL, URL(string: "https://images2.imgbox.com/3c/0e/T8iJcSN3_o.png")!)
            XCTAssertEqual((model[1].data.first as? LaunchCellViewModelType)?.videoLink, URL(string: "https://www.youtube.com/watch?v=0a_00nJ_Y88")!)
            XCTAssertEqual((model[1].data.first as? LaunchCellViewModelType)?.wikipedia, URL(string: "https://en.wikipedia.org/wiki/DemoSat")!)
            
            sut.outputs.tableDataHandler = { model in
                expectation.fulfill()

                XCTAssertEqual(model[0].title, "Company")
                XCTAssertEqual((model[0].data.first as? CompanyCellViewModelType)?.text, "SpaceX was founded by Elon Musk in 2002. It has now 7,000 employees, 3 launch sites, and is valued at USD $27,500,000,000")
                
                XCTAssertEqual(model[1].title, "Launches")
                XCTAssertEqual((model[1].data.first as? LaunchCellViewModelType)?.launchTime, "Dec 8, 2010 at 3:43 PM")
                XCTAssertEqual((model[1].data.first as? LaunchCellViewModelType)?.missionName, "COTS 1")
                XCTAssertEqual((model[1].data.first as? LaunchCellViewModelType)?.articleLink, URL(string: "https://en.wikipedia.org/wiki/SpaceX_COTS_Demo_Flight_1")!)
                XCTAssertEqual((model[1].data.first as? LaunchCellViewModelType)?.launchSuccessString, "✅")
                XCTAssertEqual((model[1].data.first as? LaunchCellViewModelType)?.patchImageURL, URL(string: "https://images2.imgbox.com/d9/3e/FfrN88ry_o.png")!)
                XCTAssertEqual((model[1].data.first as? LaunchCellViewModelType)?.videoLink, URL(string: "https://www.youtube.com/watch?v=cdLITgWKe_0")!)
                XCTAssertEqual((model[1].data.first as? LaunchCellViewModelType)?.wikipedia, URL(string: "https://en.wikipedia.org/wiki/SpaceX_COTS_Demo_Flight_1")!)
            }
            sut.inputs.filtersPress()
        }
        
        sut.inputs.viewDidLoad()
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testPullToRefresh() {
        let network = MockNetwork(jsonMaps: [:],
                                  mockedError: nil)
        
        let launchRepository = LaunchesNetwork(network: network)
        
        let sut = LaunchesViewModel(network: launchRepository) { _ in }
        
        var errorEvents = [String]()
        var tableEvents = [[LaunchesViewModel.Section]?]()
        
        let expectation = XCTestExpectation(description: "Waiting for Parsing")
        expectation.expectedFulfillmentCount = 2

        let updateJson = {
            network.jsonMaps = ["launches": "allLaunches", "info": "company"]
        }
        
        sut.outputs.errorHandler = {
            errorEvents.append($0)
        }

        sut.outputs.tableDataHandler = {
            tableEvents.append($0)
            expectation.fulfill()
            updateJson()
            
            sut.inputs.refreshPulled()
            
            sut.outputs.tableDataHandler = {
                tableEvents.append($0)
                expectation.fulfill()
                
                XCTAssertEqual(errorEvents, ["Oh no!\nan error occurred\nPlease pull to refresh\nto try again"])
                XCTAssertEqual(tableEvents, [[], $0])
            }
        }
        
        sut.inputs.viewDidLoad()
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testSectionEquatable() {
        let aSection = LaunchesViewModel.Section(title: "a", data: [])
        let bSection = LaunchesViewModel.Section(title: "a", data: [])
        
        XCTAssertEqual(aSection, bSection)
        
        let company = Company(name: "My company",
                              founder: "me",
                              founded: 111,
                              employees: 222,
                              launchSites: 333,
                              valuation: 444)

        let companySectionA = LaunchesViewModel.Section(title: "Company A", data: [CompanyCellViewModel(company: company)])
        let companySectionB = LaunchesViewModel.Section(title: "Company A", data: [CompanyCellViewModel(company: company)])
        let companySectionC = LaunchesViewModel.Section(title: "Company C", data: [CompanyCellViewModel(company: company)])

        XCTAssertEqual(companySectionA, companySectionB)
        XCTAssertNotEqual(companySectionA, companySectionC)
        
        let launchA = Launch(missionName: "Test",
                               launchYear: "1999",
                               launchDateUtc: "soinfoa",
                               launchSuccess: false,
                               links: Launch.Links(missionPatchSmall: nil,
                                                   articleLink: nil,
                                                   wikipedia: nil,
                                                   videoLink: nil),
                               rocket: Rocket(rocketName: "My Rocket",
                                              rocketType: "Super"))
        
        let launchC = Launch(missionName: "Test",
                               launchYear: "19992",
                               launchDateUtc: "soinfoa",
                               launchSuccess: false,
                               links: Launch.Links(missionPatchSmall: nil,
                                                   articleLink: nil,
                                                   wikipedia: nil,
                                                   videoLink: nil),
                               rocket: Rocket(rocketName: "My Rocket 2",
                                              rocketType: "Super"))


        let launchSectionA = LaunchesViewModel.Section(title: "Launch A", data: [LaunchCellViewModel(model: launchA)])
        let launchSectionB = LaunchesViewModel.Section(title: "Launch A", data: [LaunchCellViewModel(model: launchA)])
        let launchSectionC = LaunchesViewModel.Section(title: "Launch C", data: [LaunchCellViewModel(model: launchC)])

        XCTAssertEqual(launchSectionA, launchSectionB)
        XCTAssertNotEqual(launchSectionA, launchSectionC)
    }
}
