import Foundation

protocol CompanyCellViewModelType {
    var text: String {get}
}

struct CompanyCellViewModel: CompanyCellViewModelType, Equatable {
    var text: String
    
    init(company: Company) {
        //{companyName} was founded by {founderName} in {year}. It has now {employees} employees, {launch_sites} launch sites, and is valued at USD {valuation}
        let formatter = NumberFormatter.largeNumberFormatter
        let employeeCountString = formatter.string(for: company.employees) ?? "error"
        let launchSiteCount = formatter.string(for: company.launchSites) ?? "error"
        let valuationString = NumberFormatter.dollarCurrencyFormatter.string(for: company.valuation) ?? "error"
        text = "\(company.name) was founded by \(company.founder) in \(company.founded). It has now \(employeeCountString) employees, \(launchSiteCount) launch sites, and is valued at USD \(valuationString)"
    }
}

protocol LaunchCellViewModelType {
    var patchImageURL: URL? {get}
    var missionName: String {get}
    var launchTime: String? {get}
    var rocketDetails: String {get}
    var daysSince: (title: String, days: Int)? {get}
    var launchSuccessString: String? {get}
    var articleLink: URL? {get}
    var wikipedia: URL? {get}
    var videoLink: URL? {get}
}

struct LaunchCellViewModel: LaunchCellViewModelType, Equatable {
    static func == (lhs: LaunchCellViewModel, rhs: LaunchCellViewModel) -> Bool {
        return lhs.patchImageURL == rhs.patchImageURL &&
            lhs.missionName == rhs.missionName &&
            lhs.launchTime == rhs.launchTime &&
            lhs.rocketDetails == rhs.rocketDetails &&
            lhs.daysSince?.title == rhs.daysSince?.title &&
            lhs.daysSince?.days == rhs.daysSince?.days &&
            lhs.launchSuccessString == rhs.launchSuccessString &&
            lhs.articleLink == rhs.articleLink &&
            lhs.wikipedia == rhs.wikipedia &&
            lhs.videoLink == rhs.videoLink
    }
    
    var patchImageURL: URL?
    var missionName: String
    var launchTime: String?
    var rocketDetails: String
    var daysSince: (title: String, days: Int)?
    var launchSuccessString: String?
    var articleLink: URL?
    var wikipedia: URL?
    var videoLink: URL?
    
    init(model: Launch) {
        patchImageURL = model.links.missionPatchSmall
        missionName = model.missionName
        
        if let date = DateFormatter.launchTimeFormatter.date(from: model.launchDateUtc) {
            launchTime = date.dateAtTime()
        }
        
        rocketDetails = "\(model.rocket.rocketName) / \(model.rocket.rocketType)"
        
        if let date = DateFormatter.launchTimeFormatter.date(from: model.launchDateUtc),
           let days = Calendar.current.dateComponents([.day], from: date, to: Date()).day {
            let sinceFrom = days > 0 ? "since" : "from"
            daysSince = ("Days \(sinceFrom) now:", abs(days))
        }
        
        if let success = model.launchSuccess {
            launchSuccessString = success ? "✅" : "❌"
        }
        
        articleLink = model.links.articleLink
        wikipedia = model.links.wikipedia
        videoLink = model.links.videoLink
    }
}

extension LaunchesViewModel {
    struct Section: Equatable {
        static func == (lhs: LaunchesViewModel.Section, rhs: LaunchesViewModel.Section) -> Bool {
            if let lhsData = lhs.data as? [CompanyCellViewModel],
               let rhsData = rhs.data as? [CompanyCellViewModel] {
                let titleMatch = lhs.title == rhs.title
                let dataMatch = lhsData == rhsData
                return titleMatch && dataMatch
            } else if let lhsData = lhs.data as? [LaunchCellViewModel],
                      let rhsData = rhs.data as? [LaunchCellViewModel] {
                let titleMatch = lhs.title == rhs.title
                let dataMatch = lhsData == rhsData
                return titleMatch && dataMatch
            }
            return false
        }
        
        let title: String
        let data: [Any]
    }
}
