import XCTest
@testable import Space_X_Sean_Lintern

class FormatterTests: XCTestCase {
    func testDateAtTimeString() {
        let date = Date(timeIntervalSince1970: 0)
        
        let result = date.dateAtTime()
        
        XCTAssertEqual(result, "Jan 1, 1970 at 1:00 AM")
    }
    
    func testLargeNumberTest() {
        let number = 1000000
        
        let formatter = NumberFormatter.largeNumberFormatter
        let result = formatter.string(for: number)!

        XCTAssertEqual(result, "1,000,000")
    }
}
