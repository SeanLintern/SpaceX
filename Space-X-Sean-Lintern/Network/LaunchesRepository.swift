import Foundation

protocol LaunchesRepository {
    func getLaunches(completion: @escaping (Result<[Launch], NetworkError>) -> Void)
    func getCompanyInfo(completion: @escaping (Result<Company, NetworkError>) -> Void)
}

class LaunchesNetwork: LaunchesRepository {
    enum Endpoints {
        case allLaunches
        case companyInfo

        var url: URL? {
            switch self {
            case .allLaunches:
                return URL(string: "https://api.spacexdata.com/v3/launches")
            case .companyInfo:
                return URL(string: "https://api.spacexdata.com/v3/info")
            }
        }
    }

    private var network: Network

    init(network: Network) {
        self.network = network
    }

    func getLaunches(completion: @escaping (Result<[Launch], NetworkError>) -> Void) {
        guard let url = Endpoints.allLaunches.url else {
            completion(.failure(.malformedRequest))
            return
        }

        let request = URLRequest(url: url)

        network.perform(urlRequest: request) { result in
            do {
                let data = try result.get()
                                
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    decoder.keyDecodingStrategy = .convertFromSnakeCase

                    let launches = try decoder.decode([Launch].self, from: data)
                    
                    completion(.success(launches))
                } else {
                    completion(.failure(.noData))
                }
            } catch {
                completion(.failure(.malformedJSON))
            }
        }
    }
    
    func getCompanyInfo(completion: @escaping (Result<Company, NetworkError>) -> Void) {
        guard let url = Endpoints.companyInfo.url else {
            completion(.failure(.malformedRequest))
            return
        }

        let request = URLRequest(url: url)

        network.perform(urlRequest: request) { result in
            do {
                let data = try result.get()
                                
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    decoder.keyDecodingStrategy = .convertFromSnakeCase

                    let company = try decoder.decode(Company.self, from: data)
                    
                    completion(.success(company))
                } else {
                    completion(.failure(.noData))
                }
            } catch {
                completion(.failure(.malformedJSON))
            }
        }
    }
}
