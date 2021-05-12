import Foundation
import XCTest
@testable import Space_X_Sean_Lintern

class CompanyCellViewModelTests: XCTestCase {
    
    func testEquitable() {
        let company = Company(name: "My company",
                              founder: "me",
                              founded: 111,
                              employees: 222,
                              launchSites: 333,
                              valuation: 444)
        let sut = CompanyCellViewModel(company: company)
        let match = CompanyCellViewModel(company: company)
        
        XCTAssertEqual(sut, match)
        
        let nonMatchingCompany = Company(name: "My company 2",
                                         founder: "me",
                                         founded: 111,
                                         employees: 222,
                                         launchSites: 666,
                                         valuation: 444)
        
        let nonMatch = CompanyCellViewModel(company: nonMatchingCompany)
        
        XCTAssertNotEqual(nonMatch, match)
    }
}
