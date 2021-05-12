import Foundation
import XCTest
@testable import Space_X_Sean_Lintern

class NetworkManagerTests: XCTestCase {
    class CustomSessionHandler: URLSession {
        struct MockedResponse {
            let code: Int
            let error: NetworkError?
            let data: Data?
            let noResponse: Bool
        }
        
        private let response: MockedResponse
        
        init(response: MockedResponse) {
            self.response = response
        }
        
        override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            let result = HTTPURLResponse(url: request.url!,
                                         statusCode: response.code,
                                         httpVersion: nil,
                                         headerFields: request.allHTTPHeaderFields)
            completionHandler(response.data, response.noResponse ? nil : result, response.error)
            return URLSession.shared.dataTask(with: request, completionHandler: { _, _, _ in })
        }
    }
    
    
    func testSuccess() {
        let session = CustomSessionHandler(response: CustomSessionHandler.MockedResponse(code: 200, error: nil, data: nil, noResponse: false))
        let sut = NetworkManager(session: session)
        let expectation = XCTestExpectation(description: "Network route")
        let request = URLRequest(url: URL(string: "http://google.com")!)
        sut.perform(urlRequest: request, completion: { result in
            expectation.fulfill()
            XCTAssertEqual(try? result.get(), nil)
        })
        wait(for: [expectation], timeout: 2)
    }
    
    func testFailureCode() {
        let session = CustomSessionHandler(response: CustomSessionHandler.MockedResponse(code: 310, error: nil, data: nil, noResponse: false))
        let sut = NetworkManager(session: session)
        let expectation = XCTestExpectation(description: "Network route")
        let request = URLRequest(url: URL(string: "http://google.com")!)
        sut.perform(urlRequest: request, completion: { result in
            expectation.fulfill()
            XCTAssertEqual(try? result.get(), nil)
        })
        wait(for: [expectation], timeout: 2)
    }
    
    func testTimeout() {
        let session = CustomSessionHandler(response: CustomSessionHandler.MockedResponse(code: 200, error: nil, data: nil, noResponse: true))
        let sut = NetworkManager(session: session)
        let expectation = XCTestExpectation(description: "Network route")
        let request = URLRequest(url: URL(string: "http://google.com")!)
        sut.perform(urlRequest: request, completion: { result in
            expectation.fulfill()
            XCTAssertEqual(try? result.get(), nil)
        })
        wait(for: [expectation], timeout: 2)
    }
    
    func testData() {
        let data = MockNetwork.json(name: "company")
        let session = CustomSessionHandler(response: CustomSessionHandler.MockedResponse(code: 200, error: nil, data: data, noResponse: false))
        let sut = NetworkManager(session: session)
        let expectation = XCTestExpectation(description: "Network route")
        let request = URLRequest(url: URL(string: "http://google.com")!)
        sut.perform(urlRequest: request, completion: { result in
            expectation.fulfill()
            XCTAssertEqual(try? result.get(), data)
        })
        wait(for: [expectation], timeout: 2)
    }
}
