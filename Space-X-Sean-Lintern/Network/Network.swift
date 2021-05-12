import Foundation

enum NetworkError: Error {
    case failure(code: Int)
    case timeout
    case malformedRequest
    case malformedJSON
    case noData
}

protocol Network {
    func perform(urlRequest: URLRequest, completion: @escaping (Result<Data?, NetworkError>) -> Void)
}

class NetworkManager: Network {
    private static let successRange = 200..<309
    
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }

    func perform(urlRequest: URLRequest, completion: @escaping (Result<Data?, NetworkError>) -> Void) {
        session.dataTask(with: urlRequest, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse {
                    let code = httpResponse.statusCode

                    if NetworkManager.successRange.contains(code) {
                        completion(.success(data))
                    } else {
                        completion(.failure(.failure(code: code)))
                    }
                } else {
                    completion(.failure(.timeout))
                }
            }
        }).resume()
    }
}
