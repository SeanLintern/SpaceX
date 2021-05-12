import Foundation

protocol LaunchesViewModelProtocol {
    var inputs: LaunchesViewModelInputsProtocol {get}
    var outputs: LaunchesViewModelOutputsProtocol {get set}
}

protocol LaunchesViewModelInputsProtocol {
    func viewDidLoad()
    func showDetails(url: URL)
    func filtersPress()
    func refreshPulled()
}

protocol LaunchesViewModelOutputsProtocol {
    var loadingHandler: isLoadingHandler? {get set}
    var tableDataHandler: listDataHandler? {get set}
    var errorHandler: errorHandler? {get set}
    var title: String {get}
}

typealias isLoadingHandler = (_ isLoading: Bool) -> Void
typealias listDataHandler = (_ data: [LaunchesViewModel.Section]) -> Void
typealias errorHandler = (_ errorText: String) -> Void

class LaunchesViewModel: LaunchesViewModelProtocol {
    typealias LaunchesViewModelFlow = (_ event: Events) -> Void

    enum Events: Equatable {
        static func == (lhs: LaunchesViewModel.Events, rhs: LaunchesViewModel.Events) -> Bool {
            switch (lhs, rhs) {
            case (.showURL(let lhsURL), .showURL(let rhsURL)):
                return lhsURL == rhsURL
            case (.showFilters(let lhsModel, let lhsYears, _), .showFilters(let rhsModel, let rhsYears, _)):
                return lhsModel == rhsModel && lhsYears == rhsYears
            default:
                return false
            }
        }
        
        case showFilters(existing: FilterModel?, years: [String], callBack: (_ model: FilterModel?) -> Void)
        case showURL(URL)
    }
    
    let inputs: LaunchesViewModelInputsProtocol
    var outputs: LaunchesViewModelOutputsProtocol

    private var network: LaunchesRepository
    
    init(network: LaunchesRepository, flow: @escaping LaunchesViewModelFlow) {
        self.network = network

        let outputs = Outputs()
        self.outputs = outputs

        let inputs = Inputs(onLoad: {
            LaunchesViewModel.loadData(repository: network,
                                       outputs: outputs)
        }, onSelectItem: { url in
            flow(.showURL(url))
        }, onFiltersPress: {
            guard outputs.company != nil && outputs.launches != nil else { return }
            flow(.showFilters(existing: outputs.filters,
                              years: outputs.availableYears,
                              callBack: { outputs.filters = $0 }))
        }, refresh: {
            LaunchesViewModel.loadData(repository: network,
                                       outputs: outputs)
        })

        self.inputs = inputs
    }
    
    private static func loadData(repository: LaunchesRepository,
                                 outputs: Outputs) {
        outputs.loadingHandler?(true)
        
        let group = DispatchGroup()

        for _ in 0..<2 { group.enter() }
        
        var company: Company?
        var launches: [Launch]?

        group.notify(queue: .main) {
            outputs.loadingHandler?(false)
            
            guard let company = company,
                  let launches = launches else {
                outputs.errorText = "Oh no!\nan error occurred\nPlease pull to refresh\nto try again"
                return
            }

            outputs.launches = launches
            outputs.company = company
        }
        
        repository.getCompanyInfo { result in
            company = try? result.get()
            group.leave()
        }
        
        repository.getLaunches { result in
            launches = try? result.get()
            group.leave()
        }
    }
}

extension LaunchesViewModel {
    class Inputs: LaunchesViewModelInputsProtocol {
        let onLoad: () -> Void
        let onSelectItem: (_ url: URL) -> Void
        let onFiltersPress: () -> Void
        let refresh: () -> Void

        init(onLoad: @escaping () -> Void,
             onSelectItem: @escaping (_ url: URL) -> Void,
             onFiltersPress: @escaping () -> Void,
             refresh: @escaping () -> Void) {
            self.onLoad = onLoad
            self.onSelectItem = onSelectItem
            self.onFiltersPress = onFiltersPress
            self.refresh = refresh
        }

        func viewDidLoad() {
            onLoad()
        }
        
        func showDetails(url: URL) {
            onSelectItem(url)
        }
        
        func filtersPress() {
            onFiltersPress()
        }
        
        func refreshPulled() {
            refresh()
        }
    }
}

extension LaunchesViewModel {
    class Outputs: LaunchesViewModelOutputsProtocol {
        var company: Company? {
            didSet {
                buildData(company: company, launches: launches, filters: filters)
            }
        }
        
        var launches: [Launch]? {
            didSet {
                buildAvailableYears()
                buildData(company: company, launches: launches, filters: filters)
            }
        }
        
        var errorText: String? {
            didSet {
                if let text = errorText {
                    errorHandler?(text)
                    tableDataHandler?([])
                }
            }
        }
        
        var errorHandler: errorHandler?
        var loadingHandler: isLoadingHandler?
        var tableDataHandler: listDataHandler?
        
        var filters: FilterModel? {
            didSet {
                buildData(company: company, launches: launches, filters: filters)
            }
        }
        
        fileprivate var availableYears = [String]()
        
        let title: String = "SpaceX"
        
        private func buildData(company: Company?, launches: [Launch]?, filters: FilterModel?) {
            guard let company = company, let launches = launches else {
                return
            }
            
            let companySection = LaunchesViewModel.Section(title: "Company", data: [CompanyCellViewModel(company: company)])
            
            var filteredLaunches = launches

            if let year = filters?.launchYear {
                filteredLaunches = filteredLaunches.filter({Int($0.launchYear) == year})
            }
            if let success = filters?.landingSuccess {
                filteredLaunches = filteredLaunches.filter({
                    if let launchSuccess = $0.launchSuccess {
                        return launchSuccess == success
                    }
                    return false
                })
            }
            if let isAscending = filters?.isAscending, !isAscending {
                filteredLaunches = filteredLaunches.reversed()
            }

            let launchModels = filteredLaunches.map({ LaunchCellViewModel(model: $0) })
            let launchesSection = LaunchesViewModel.Section(title: "Launches",
                                                         data: launchModels)

            tableDataHandler?([companySection, launchesSection])
        }
        
        private func buildAvailableYears() {
            guard let launches = launches, !launches.isEmpty else { return }
            let uniqueYears = launches.map({ $0.launchYear })
            let yearsSet = Set(uniqueYears)
            let sortedYears = yearsSet.sorted { (a, b) -> Bool in
                if let lhs = Int(a), let rhs = Int(b) {
                    return lhs > rhs
                }
                return false
            }
            availableYears = Array(sortedYears)
        }
    }
}
