import Foundation
import SwiftData

@Model
final class CalendarEvent {
    var id: UUID
    var title: String
    var notes: String
    var location: String
    var startDate: Date
    var endDate: Date
    var isAllDay: Bool
    var recurrenceRule: String?
    var alertMinutesBefore: Int?
    var estimatedDurationMinutes: Int?
    var travelTimeMinutes: Int?
    var externalEventID: String?
    var createdAt: Date
    var updatedAt: Date

    var category: CalendarCategory?

    @Relationship(deleteRule: .cascade, inverse: \TodoItem.linkedEvent)
    var linkedTodos: [TodoItem] = []

    init(
        title: String,
        notes: String = "",
        location: String = "",
        startDate: Date,
        endDate: Date,
        isAllDay: Bool = false,
        category: CalendarCategory? = nil,
        recurrenceRule: String? = nil,
        alertMinutesBefore: Int? = 15,
        estimatedDurationMinutes: Int? = nil,
        travelTimeMinutes: Int? = nil,
        externalEventID: String? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.notes = notes
        self.location = location
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.category = category
        self.recurrenceRule = recurrenceRule
        self.alertMinutesBefore = alertMinutesBefore
        self.estimatedDurationMinutes = estimatedDurationMinutes
        self.travelTimeMinutes = travelTimeMinutes
        self.externalEventID = externalEventID
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var durationMinutes: Int {
        Int(endDate.timeIntervalSince(startDate) / 60)
    }

    var spansMultipleDays: Bool {
        !Calendar.current.isDate(startDate, inSameDayAs: endDate)
    }
}
