import Foundation

protocol FiltersViewModelProtocol {
    var inputs: FiltersViewModelInputsProtocol {get}
    var outputs: FiltersViewModelOutputsProtocol {get set}
}

protocol FiltersViewModelInputsProtocol {
    func viewDidLoad()
    func setLaunchYear(value: String)
    func setLandingSuccess(segment: Int)
    func setAscending(segment: Int)
    func applyPress()
    func clearPress()
}

protocol FiltersViewModelOutputsProtocol {
    var launchYearUpdate: ((_ value: String) -> Void)? {get set}
    var successUpdate: ((_ segment: Int) -> Void)? {get set}
    var ascendingUpdate: ((_ segment: Int) -> Void)? {get set}
    var yearPickerData: [String] {get}
}

class FiltersViewModel: FiltersViewModelProtocol {
    typealias FiltersViewModelFlow = (_ event: Events) -> Void
    enum Events: Equatable {
        case completedFilters(model: FilterModel)
    }
    
    var inputs: FiltersViewModelInputsProtocol
    var outputs: FiltersViewModelOutputsProtocol
    
    private static let noneValue = "None"
    
    init(existingModel: FilterModel?, availableYears: [String] = [], flow: @escaping FiltersViewModelFlow) {
        let outputs = Outputs(availableYears: availableYears)
        outputs.launchYear = existingModel?.launchYear
        outputs.landingSuccess = existingModel?.landingSuccess
        outputs.isAscending = existingModel?.isAscending ?? outputs.isAscending
        self.outputs = outputs
        
        inputs = Inputs(onLoad: {
            outputs.updateAllValues()
        },
        launchYearUpdate: { outputs.launchYear = $0 },
        successUpdate: { outputs.landingSuccess = $0 },
        ascendingUpdate: { outputs.isAscending = $0 },
        apply: {
            let model = FilterModel(launchYear: outputs.launchYear,
                                    landingSuccess: outputs.landingSuccess,
                                    isAscending: outputs.isAscending)
            flow(.completedFilters(model: model))
        }, clear: {
            outputs.launchYear = nil
            outputs.landingSuccess = nil
            outputs.isAscending = true
            outputs.updateAllValues()
        })
    }
}

extension FiltersViewModel {
    class Inputs: FiltersViewModelInputsProtocol {
        
        let onLoad: () -> Void
        let launchYearUpdate: (_ year: Int?) -> Void
        let successUpdate: (_ success: Bool?) -> Void
        let ascendingUpdate: (_ ascending: Bool) -> Void
        let apply: () -> Void
        let clear: () -> Void
        
        init(onLoad: @escaping () -> Void,
             launchYearUpdate: @escaping (_ year: Int?) -> Void,
             successUpdate: @escaping (_ success: Bool?) -> Void,
             ascendingUpdate: @escaping (_ ascending: Bool) -> Void,
             apply: @escaping () -> Void,
             clear: @escaping () -> Void) {
            self.onLoad = onLoad
            self.launchYearUpdate = launchYearUpdate
            self.successUpdate = successUpdate
            self.ascendingUpdate = ascendingUpdate
            self.apply = apply
            self.clear = clear
        }
        
        func viewDidLoad() {
            onLoad()
        }
        
        func setLaunchYear(value: String) {
            if value == FiltersViewModel.noneValue {
                launchYearUpdate(nil)
            } else if let year = Int(value) {
                launchYearUpdate(year)
            }
        }
        
        func setLandingSuccess(segment: Int) {
            switch segment {
            case 0:
                successUpdate(nil)
            case 1:
                successUpdate(true)
            case 2:
                successUpdate(false)
            default:
                break
            }
        }
        
        func setAscending(segment: Int) {
            switch segment {
            case 0:
                ascendingUpdate(true)
            case 1:
                ascendingUpdate(false)
            default:
                break
            }
        }
        
        func applyPress() {
            apply()
        }
        
        func clearPress() {
            clear()
        }
    }
}

extension FiltersViewModel {
    class Outputs: FiltersViewModelOutputsProtocol {
        var launchYear: Int? {
            didSet {
                launchYearUpdate(update: launchYear)
            }
        }
        
        var landingSuccess: Bool? {
            didSet {
                successUpdate(value: landingSuccess)
            }
        }
        
        var isAscending: Bool = true{
            didSet {
                ascendingUpdate(value: isAscending)
            }
        }
        
        var yearPickerData: [String]
        
        var launchYearUpdate: ((_ value: String) -> Void)?
        var successUpdate: ((_ segment: Int) -> Void)?
        var ascendingUpdate: ((_ segment: Int) -> Void)?
        
        init(availableYears: [String]) {
            if !availableYears.isEmpty {
                var addedNoneValue = [FiltersViewModel.noneValue]
                addedNoneValue.append(contentsOf: availableYears)
                yearPickerData = addedNoneValue
            } else {
                var years = [FiltersViewModel.noneValue]
                let year = Calendar.current.component(.year, from: Date())
                for aYear in stride(from: year, to: 1901, by: -1) {
                    years.append("\(aYear)")
                }
                yearPickerData = years
            }
        }
        
        func updateAllValues() {
            launchYearUpdate(update: launchYear)
            successUpdate(value: landingSuccess)
            ascendingUpdate(value: isAscending)
        }
        
        func launchYearUpdate(update: Int?) {
            let newValue = update == nil ? FiltersViewModel.noneValue : "\(update!)"
            launchYearUpdate?(newValue)
        }
        
        func successUpdate(value: Bool?) {
            let newValue = value == nil ? 0 : value! ? 1 : 2
            successUpdate?(newValue)
        }
        
        func ascendingUpdate(value: Bool) {
            ascendingUpdate?(value ? 0 : 1)
        }
    }
}
