import Foundation
import XCTest
@testable import Space_X_Sean_Lintern

class FiltersViewModelTests: XCTestCase {
    func testExistingModel() {
        let model = FilterModel(launchYear: 1111, landingSuccess: true, isAscending: false)
        
        var flows = [FiltersViewModel.Events]()
        
        let sut = FiltersViewModel(existingModel: model) {
            flows.append($0)
        }
        
        sut.inputs.applyPress()
        
        XCTAssertEqual(flows, [.completedFilters(model: model)])
    }
    
    func testNilInitialModel() {
        var flows = [FiltersViewModel.Events]()
        
        let sut = FiltersViewModel(existingModel: nil) {
            flows.append($0)
        }
        
        sut.inputs.applyPress()
        
        XCTAssertEqual(flows, [.completedFilters(model: FilterModel(launchYear: nil, landingSuccess: nil, isAscending: true))])
    }
    
    func testClearingModel() {
        let model = FilterModel(launchYear: 1111, landingSuccess: true, isAscending: false)
        
        var flows = [FiltersViewModel.Events]()
        
        let sut = FiltersViewModel(existingModel: model) {
            flows.append($0)
        }
        
        sut.inputs.clearPress()
        sut.inputs.applyPress()

        XCTAssertEqual(flows, [.completedFilters(model: FilterModel(launchYear: nil, landingSuccess: nil, isAscending: true))])
    }

    func testUpdatingValues() {
        let model = FilterModel(launchYear: 1111, landingSuccess: true, isAscending: false)
        
        var flows = [FiltersViewModel.Events]()
        
        let sut = FiltersViewModel(existingModel: model) {
            flows.append($0)
        }
        
        sut.inputs.setLandingSuccess(segment: 2)
        sut.inputs.setAscending(segment: 1)
        sut.inputs.setLaunchYear(value: "1999")

        sut.inputs.applyPress()

        XCTAssertEqual(flows, [.completedFilters(model: FilterModel(launchYear: 1999, landingSuccess: false, isAscending: false))])
    }
    
    func testInitialValues() {
        let model = FilterModel(launchYear: 1111, landingSuccess: true, isAscending: false)
                
        let sut = FiltersViewModel(existingModel: model) { _ in }

        var yearUpdates = [String]()
        var landingUpdates = [Int]()
        var ascendingUpdates = [Int]()
        
        sut.outputs.launchYearUpdate = {
            yearUpdates.append($0)
        }
        
        sut.outputs.successUpdate = {
            landingUpdates.append($0)
        }
        
        sut.outputs.ascendingUpdate = {
            ascendingUpdates.append($0)
        }
        
        sut.inputs.viewDidLoad()
        
        XCTAssertEqual(yearUpdates, ["1111"])
        XCTAssertEqual(landingUpdates, [1])
        XCTAssertEqual(ascendingUpdates, [1])
    }
    
    func testAllValues() {
        let model = FilterModel(launchYear: 1111, landingSuccess: true, isAscending: false)
                
        let sut = FiltersViewModel(existingModel: model) { _ in }

        var yearUpdates = [String]()
        var landingUpdates = [Int]()
        var ascendingUpdates = [Int]()
        
        sut.outputs.launchYearUpdate = {
            yearUpdates.append($0)
        }
        
        sut.outputs.successUpdate = {
            landingUpdates.append($0)
        }
        
        sut.outputs.ascendingUpdate = {
            ascendingUpdates.append($0)
        }
        
        sut.inputs.viewDidLoad()
        
        sut.inputs.setLandingSuccess(segment: 0)
        sut.inputs.setAscending(segment: 0)
        sut.inputs.setLaunchYear(value: "1999")

        XCTAssertEqual(yearUpdates, ["1111", "1999"])
        XCTAssertEqual(landingUpdates, [1, 0])
        XCTAssertEqual(ascendingUpdates, [1, 0])
    }

    func testInvalidValues() {
        let model = FilterModel(launchYear: 1111, landingSuccess: true, isAscending: false)
                
        let sut = FiltersViewModel(existingModel: model) { _ in }

        var yearUpdates = [String]()
        var landingUpdates = [Int]()
        var ascendingUpdates = [Int]()
        
        sut.outputs.launchYearUpdate = {
            yearUpdates.append($0)
        }
        
        sut.outputs.successUpdate = {
            landingUpdates.append($0)
        }
        
        sut.outputs.ascendingUpdate = {
            ascendingUpdates.append($0)
        }
        
        sut.inputs.viewDidLoad()
        
        sut.inputs.setLandingSuccess(segment: 7)
        sut.inputs.setAscending(segment: 99)
        sut.inputs.setLaunchYear(value: "Purple Battery Horse")

        XCTAssertEqual(yearUpdates, ["1111"])
        XCTAssertEqual(landingUpdates, [1])
        XCTAssertEqual(ascendingUpdates, [1])
        
        sut.inputs.setLandingSuccess(segment: 1)
        sut.inputs.setLaunchYear(value: "None")

        XCTAssertEqual(yearUpdates, ["1111", "None"])
        XCTAssertEqual(landingUpdates, [1, 1])
        XCTAssertEqual(ascendingUpdates, [1])
    }
}
