import Foundation
@testable import Space_X_Sean_Lintern

class MockNetwork: Network {
    var jsonMaps: [String: String]
    private let mockedError: NetworkError?

    init(jsonMaps: [String: String], mockedError: NetworkError?) {
        self.jsonMaps = jsonMaps
        self.mockedError = mockedError
    }
    
    func perform(urlRequest: URLRequest, completion: @escaping (Result<Data?, NetworkError>) -> Void) {
        guard mockedError == nil else {
            completion(.failure(mockedError!))
            return
        }
        
        guard let path = urlRequest.url?.lastPathComponent, let jsonName = jsonMaps[path] else {
            completion(.failure(.noData))
            return
        }
        
        completion(.success(Self.json(name: jsonName)))
    }
    
    static func json(name: String) -> Data? {
        if let path = Bundle.main.path(forResource: name, ofType: "json"),
           let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe) {
            return jsonData
        }
        return nil
    }
}
