import Foundation

extension Date {

    /// "Mar 4, 2026"
    var mediumFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    /// "4 Mar"
    var shortDayMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: self)
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
