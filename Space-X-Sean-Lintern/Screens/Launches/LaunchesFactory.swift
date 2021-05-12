import UIKit

struct LaunchesFactory {
    /* If you want to show the screen through a different coordinator, you just have to write
       another static func here passing in the different coordinator and mapping the outbound events.
    */
    static func showLaunches(context: UINavigationController,
                             repository: LaunchesRepository,
                             coordintator: LaunchesCoordinator) {
        let viewmodel = LaunchesViewModel(network: repository) { event in
            switch event {
            case .showURL(let url):
                coordintator.loop(event: .didSelectLaunchArticle(url))
            case .showFilters(let existing, let years, let callback):
                coordintator.loop(event: .didSelectShowFilters(existing: existing, years: years, callBack: callback))
            }
        }
        let controller = LaunchesViewController.instantiate(viewModel: viewmodel)
        context.pushViewController(controller, animated: true)
    }
}
