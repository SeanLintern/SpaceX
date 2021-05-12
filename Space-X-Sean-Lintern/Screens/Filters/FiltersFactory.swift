import UIKit

struct FiltersFactory {
    static func showFilters(context: UINavigationController,
                            existingModel: FilterModel?,
                            availableYears: [String],
                            completion: @escaping (_ model: FilterModel?) -> Void) {
        let viewModel = FiltersViewModel(existingModel: existingModel, availableYears: availableYears) { (event) in
            if case let .completedFilters(model) = event {
                completion(model)
                context.dismiss(animated: true, completion: nil)
            }
        }
        let controller = FiltersViewController.instantiate(viewModel: viewModel)
        context.present(controller, animated: true, completion: nil)
    }
}
