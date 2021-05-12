import UIKit

class LaunchesCoordinator: Coordinator {
    enum Event: Equatable {
        static func == (lhs: LaunchesCoordinator.Event, rhs: LaunchesCoordinator.Event) -> Bool {
            switch (lhs, rhs) {
            case(.initial, .initial):
                return true
            case(.invalid, .invalid):
                return true
            case(.willShowLaunches, .willShowLaunches):
                return true
            case(.didSelectLaunchArticle(let urlA), .didSelectLaunchArticle(let urlB)):
                return urlA == urlB
            case(.willShowWebpage(let urlA), .willShowWebpage(let urlB)):
                return urlA == urlB
            case(.didSelectShowFilters(let existingA, let yearsA, _), .didSelectShowFilters(let existingB, let yearsB, _)):
                return existingA == existingB && yearsA == yearsB
            case(.willShowFilters(let existingA, let yearsA, _), .willShowFilters(let existingB, let yearsB, _)):
                return existingA == existingB && yearsA == yearsB
            default:
                return false
            }
        }
        
        case initial
        case invalid

        case willShowLaunches
        
        case didSelectShowFilters(existing: FilterModel?, years: [String], callBack: (_ model: FilterModel?) -> Void)
        case willShowFilters(existing: FilterModel?, years: [String], callBack: (_ model: FilterModel?) -> Void)
        
        case didSelectLaunchArticle(URL)
        case willShowWebpage(URL)
    }

    var children = [Coordinator]()

    var context: UINavigationController!

    var repository: LaunchesRepository

    init(context: UINavigationController, network: Network) {
        self.context = context
        self.repository = LaunchesNetwork(network: network)
    }

    func start() {
        loop(event: .initial)
    }

    func loop(event: Event) {
        let next = Self.state(event: event)

        switch next {
        case .willShowLaunches:
            LaunchesFactory.showLaunches(context: context,
                                         repository: repository,
                                         coordintator: self)
        
        case .willShowFilters(let existing, let years, let callBack):
            FiltersFactory.showFilters(context: context,
                                       existingModel: existing,
                                       availableYears: years,
                                       completion: callBack)
            
        case .willShowWebpage(let url):
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }

        default:
            fatalError("Unhandled state \(String(describing: self))")
        }
    }
}

extension LaunchesCoordinator {
    static func state(event: Event) -> Event {
        switch event {
        case .initial:
            return .willShowLaunches
        case .didSelectLaunchArticle(let url):
            return .willShowWebpage(url)
        case .didSelectShowFilters(let existing, let years, let callBack):
            return .willShowFilters(existing: existing, years: years, callBack: callBack)
        default:
            return .invalid
        }
    }
}
