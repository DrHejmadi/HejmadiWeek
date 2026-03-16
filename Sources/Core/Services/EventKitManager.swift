import EventKit
import SwiftUI

@Observable
final class EventKitManager {
    static let shared = EventKitManager()

    private let store = EKEventStore()
    private(set) var isAuthorized = false
    private(set) var ekEvents: [EKEvent] = []
    private(set) var ekCalendars: [EKCalendar] = []

    private init() {
        checkAuthorization()
    }

    func checkAuthorization() {
        let status = EKEventStore.authorizationStatus(for: .event)
        isAuthorized = status == .fullAccess || status == .authorized
    }

    func requestAccess() async -> Bool {
        do {
            let granted: Bool
            if #available(iOS 17.0, macOS 14.0, *) {
                granted = try await store.requestFullAccessToEvents()
            } else {
                granted = try await store.requestAccess(to: .event)
            }
            await MainActor.run {
                isAuthorized = granted
            }
            return granted
        } catch {
            return false
        }
    }

    func fetchEvents(from startDate: Date, to endDate: Date) {
        guard isAuthorized else { return }
        let predicate = store.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let events = store.events(matching: predicate)
        ekEvents = events
        ekCalendars = store.calendars(for: .event)
    }

    func fetchEventsForMonth(containing date: Date) {
        let cal = Calendar.current
        guard let start = cal.date(byAdding: .month, value: -1, to: date.startOfDay),
              let end = cal.date(byAdding: .month, value: 2, to: date.startOfDay) else { return }
        fetchEvents(from: start, to: end)
    }

    func eventsFor(date: Date) -> [DisplayEvent] {
        let dayStart = date.startOfDay
        let dayEnd = date.endOfDay
        return ekEvents
            .filter { event in
                if event.isAllDay {
                    return event.startDate <= dayEnd && event.endDate >= dayStart
                }
                return event.startDate < dayEnd && event.endDate > dayStart
            }
            .map { DisplayEvent(ekEvent: $0) }
    }
}

struct DisplayEvent: Identifiable {
    let id: String
    let title: String
    let notes: String
    let location: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    let color: Color
    let calendarName: String
    let isExternal: Bool
    let sourceEvent: CalendarEvent?
    let ekEventID: String?

    init(event: CalendarEvent) {
        self.id = event.id.uuidString
        self.title = event.title
        self.notes = event.notes
        self.location = event.location
        self.startDate = event.startDate
        self.endDate = event.endDate
        self.isAllDay = event.isAllDay
        self.color = event.category?.color ?? .blue
        self.calendarName = event.category?.name ?? "HejmadiWeek"
        self.isExternal = false
        self.sourceEvent = event
        self.ekEventID = nil
    }

    init(ekEvent: EKEvent) {
        self.id = ekEvent.eventIdentifier ?? UUID().uuidString
        self.title = ekEvent.title ?? ""
        self.notes = ekEvent.notes ?? ""
        self.location = ekEvent.location ?? ""
        self.startDate = ekEvent.startDate
        self.endDate = ekEvent.endDate
        self.isAllDay = ekEvent.isAllDay
        self.color = Color(cgColor: ekEvent.calendar.cgColor)
        self.calendarName = ekEvent.calendar.title
        self.isExternal = true
        self.sourceEvent = nil
        self.ekEventID = ekEvent.eventIdentifier
    }

    var durationMinutes: Int {
        max(0, Int(endDate.timeIntervalSince(startDate) / 60))
    }

    var timeString: String {
        startDate.timeString
    }
}
