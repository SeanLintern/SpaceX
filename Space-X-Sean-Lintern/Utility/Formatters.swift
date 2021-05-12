import Foundation

extension NumberFormatter {
    
    /// Provides a formatter that formats numbers using the ',' to group numbers
    static var largeNumberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter
    }
    
    static var dollarCurrencyFormatter: NumberFormatter {
        let formatter = largeNumberFormatter
        formatter.currencySymbol = "$"
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter
    }
}

extension DateFormatter {
    /// Formatter for Launch time 8601 with internet seconds and fractional time
    static var launchTimeFormatter: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }
    
    /// Provides a formatter that formats dates as "MMM DD, YYYY" with no time
    static var prettyDateOnlyFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    /// Provides a formatter that formats time as "HH:MM ZZ" with no date
    static var timeOnlyFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }
}

extension Date {
    /// Formats a date into a string in the format "MMM DD, YYYY 'at'  HH:MM ZZ"
    /// - Returns: String representation of the date in the above format
    func dateAtTime() -> String {
        return "\(DateFormatter.prettyDateOnlyFormatter.string(from: self)) at \(DateFormatter.timeOnlyFormatter.string(from: self))"
    }
}
