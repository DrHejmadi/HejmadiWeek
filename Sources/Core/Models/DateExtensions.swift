import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        Calendar.current.date(byAdding: DateComponents(day: 1, second: -1), to: startOfDay)!
    }

    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components)!
    }

    var endOfMonth: Date {
        Calendar.current.date(byAdding: DateComponents(month: 1, second: -1), to: startOfMonth)!
    }

    var startOfWeek: Date {
        var cal = Calendar.current
        cal.firstWeekday = 2 // Monday
        let components = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return cal.date(from: components)!
    }

    var weekNumber: Int {
        Calendar.current.component(.weekOfYear, from: self)
    }

    var dayOfMonth: Int {
        Calendar.current.component(.day, from: self)
    }

    var monthName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "da_DK")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: self).capitalized
    }

    var shortDayName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "da_DK")
        formatter.dateFormat = "EEE"
        return formatter.string(from: self).capitalized
    }

    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }

    func daysInMonth() -> [Date] {
        let range = Calendar.current.range(of: .day, in: .month, for: self)!
        return range.compactMap { day -> Date? in
            var components = Calendar.current.dateComponents([.year, .month], from: self)
            components.day = day
            return Calendar.current.date(from: components)
        }
    }

    func monthGridDates() -> [Date] {
        var cal = Calendar.current
        cal.firstWeekday = 2 // Monday
        let firstOfMonth = self.startOfMonth
        let firstWeekday = cal.component(.weekday, from: firstOfMonth)
        let offset = (firstWeekday - cal.firstWeekday + 7) % 7

        var dates: [Date] = []
        for i in -offset..<(42 - offset) {
            if let date = cal.date(byAdding: .day, value: i, to: firstOfMonth) {
                dates.append(date)
            }
        }
        // Trim to show 5 or 6 weeks as needed
        while dates.count > 35 {
            if let last = dates.last,
               Calendar.current.component(.month, from: last) != Calendar.current.component(.month, from: firstOfMonth),
               dates.count > 35 {
                // Keep 42 dates (6 weeks) if the month needs it
                break
            }
            break
        }
        return dates
    }

    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    func isSameMonth(as other: Date) -> Bool {
        let cal = Calendar.current
        return cal.component(.month, from: self) == cal.component(.month, from: other) &&
               cal.component(.year, from: self) == cal.component(.year, from: other)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isWeekend: Bool {
        Calendar.current.isDateInWeekend(self)
    }
}
