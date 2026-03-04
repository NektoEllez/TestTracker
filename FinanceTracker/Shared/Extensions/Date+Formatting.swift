import Foundation

private enum DateFormatting {
    static let mediumFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()
    static let shortDayMonthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d MMM"
        return f
    }()
}

extension Date {
    
        /// "Mar 4, 2026"
    var mediumFormatted: String {
        DateFormatting.mediumFormatter.string(from: self)
    }
    
        /// "4 Mar"
    var shortDayMonth: String {
        DateFormatting.shortDayMonthFormatter.string(from: self)
    }
    
        /// Returns a date with time components stripped (midnight)
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
        /// Check if date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
        /// Check if date is yesterday
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
        /// Human-readable section header: "Today", "Yesterday", or "Mar 4, 2026"
    var sectionTitle: String {
        if isToday { return "Today" }
        if isYesterday { return "Yesterday" }
        return mediumFormatted
    }
}
