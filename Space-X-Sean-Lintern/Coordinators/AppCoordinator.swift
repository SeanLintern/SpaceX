import UIKit

protocol Coordinator {
    var children: [Coordinator] {get}
    func start()
}

class AppCoordinator: Coordinator {
    enum Event {
        case initial
        case invalid

        case willShowLaunches
    }

    var children = [Coordinator]()

    var context: UINavigationController

    var network = NetworkManager(session: URLSession.shared)

    init(context: UINavigationController) {
        self.context = context
    }

    func start() {
        loop(event: .initial)
    }

    private func loop(event: Event) {
        let next = Self.state(event: event)

        switch next {
        case .willShowLaunches:
            let coordinator = LaunchesCoordinator(context: context,
                                                 network: network)
            children.append(coordinator)
            coordinator.start()
        default:
            fatalError("Unhandled state \(String(describing: self))")
        }
    }
}

extension AppCoordinator {
    static func state(event: Event) -> Event {
        switch event {
        case .initial:
            return .willShowLaunches

        default:
            return .invalid
        }
    }
}
