import UIKit

struct UITestHelperCoordinator: Coordinator {
    var children = [Coordinator]()

    private var context: UINavigationController
    
    init(context: UINavigationController) {
        self.context = context
    }
    
    func start() {
        let availableControllers: [String: UIViewController] = [
            "launches": Self.launches,
            "launchesError": Self.launchesError,
            "filters": Self.filters,
            "filtersExisting": Self.filtersExisting
        ]
        
        guard let sut = ProcessInfo.processInfo.environment["UITests"],
              let controller = availableControllers[sut] else {
            return
        }
        
        context.pushViewController(controller, animated: false)
    }
    
    private static var launches: UIViewController {
        let mockNetwork = MockNetwork(jsonMaps: ["launches": "allLaunches", "info": "company"], mockedError: nil)
        let repository = LaunchesNetwork(network: mockNetwork)
        let viewmodel = LaunchesViewModel(network: repository) { _ in }
        let controller = LaunchesViewController.instantiate(viewModel: viewmodel)
        return controller
    }
    
    private static var launchesError: UIViewController {
        let mockNetwork = MockNetwork(jsonMaps: ["launches": "", "info": ""], mockedError: nil)
        let repository = LaunchesNetwork(network: mockNetwork)
        let viewmodel = LaunchesViewModel(network: repository) { _ in }
        let controller = LaunchesViewController.instantiate(viewModel: viewmodel)
        return controller
    }
    
    private static var filters: UIViewController {
        let viewmodel = FiltersViewModel(existingModel: nil, availableYears: [], flow: { _ in })
        let controller = FiltersViewController.instantiate(viewModel: viewmodel)
        return controller
    }
    
    private static var filtersExisting: UIViewController {
        let model = FilterModel(launchYear: 1999, landingSuccess: true, isAscending: false)
        let viewmodel = FiltersViewModel(existingModel: model, availableYears: ["1999"], flow: { _ in })
        let controller = FiltersViewController.instantiate(viewModel: viewmodel)
        return controller
    }
}
