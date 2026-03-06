import Foundation

extension Date {
    
        /// "Mar 4, 2026"
    var mediumFormatted: String {
        self.formatted(date: .abbreviated, time: .omitted)
    }
    
        /// "4 Mar"
    var shortDayMonth: String {
        self.formatted(.dateTime.day().month(.abbreviated))
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
        if isToday || isYesterday {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            formatter.doesRelativeDateFormatting = true
            return formatter.string(from: self)
        }
        return mediumFormatted
    }
}
