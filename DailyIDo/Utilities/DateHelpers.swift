import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }

    func daysUntil(_ date: Date) -> Int {
        let calendar = Calendar.current
        let fromDate = calendar.startOfDay(for: self)
        let toDate = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: fromDate, to: toDate).day ?? 0
    }

    func daysSince(_ date: Date) -> Int {
        return date.daysUntil(self)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }

    func isSameDay(as date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }

    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }

    func adding(months: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
    }

    var formattedLong: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: self)
    }

    var formattedMedium: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }

    var formattedShort: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: self)
    }

    var formattedMonthDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: self)
    }

    var formattedMonthDayYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: self)
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    var formattedDayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }
}

extension TimeInterval {
    static let minute: TimeInterval = 60
    static let hour: TimeInterval = 60 * minute
    static let day: TimeInterval = 24 * hour
    static let week: TimeInterval = 7 * day
}

struct DateRange: Sequence {
    let startDate: Date
    let endDate: Date

    func makeIterator() -> DateRangeIterator {
        DateRangeIterator(startDate: startDate, endDate: endDate)
    }
}

struct DateRangeIterator: IteratorProtocol {
    var currentDate: Date
    let endDate: Date

    init(startDate: Date, endDate: Date) {
        self.currentDate = startDate
        self.endDate = endDate
    }

    mutating func next() -> Date? {
        guard currentDate <= endDate else { return nil }
        let date = currentDate
        currentDate = currentDate.adding(days: 1)
        return date
    }
}
