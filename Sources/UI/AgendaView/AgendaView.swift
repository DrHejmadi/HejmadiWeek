import SwiftUI
import SwiftData

struct AgendaView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CalendarEvent.startDate) private var allEvents: [CalendarEvent]
    @State private var showEventEditor = false
    @State private var editingEvent: CalendarEvent?
    @State private var ekManager = EventKitManager.shared

    var body: some View {
        List {
            ForEach(groupedDisplayEvents, id: \.date) { group in
                Section {
                    ForEach(group.events, id: \.id) { event in
                        AgendaDisplayEventRow(event: event)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if let source = event.sourceEvent {
                                    editingEvent = source
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                if !event.isExternal, let source = event.sourceEvent {
                                    Button(role: .destructive) {
                                        modelContext.delete(source)
                                    } label: {
                                        Label("Slet", systemImage: "trash")
                                    }
                                }
                            }
                    }
                } header: {
                    HStack {
                        Text(group.date.formatted(.dateTime.weekday(.wide).day().month(.wide).locale(Locale(identifier: "da_DK"))))
                            .font(.subheadline.weight(.semibold))
                        if group.date.isToday {
                            Text("I dag")
                                .font(.caption.weight(.bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.accentColor)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            if groupedDisplayEvents.isEmpty {
                ContentUnavailableView(
                    "Ingen kommende begivenheder",
                    systemImage: "calendar.badge.plus",
                    description: Text("Tryk + for at tilføje en begivenhed")
                )
            }
        }
        #if os(iOS)
        .listStyle(.insetGrouped)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Tilføj begivenhed", systemImage: "plus") {
                    showEventEditor = true
                }
                .labelStyle(.iconOnly)
            }
        }
        .sheet(isPresented: $showEventEditor) {
            EventEditorView()
        }
        .sheet(item: $editingEvent) { event in
            EventEditorView(initialDate: event.startDate, existingEvent: event)
        }
        .onAppear {
            Task {
                if !ekManager.isAuthorized {
                    await ekManager.requestAccess()
                }
                ekManager.fetchEventsForMonth(containing: Date())
            }
        }
    }

    private var groupedDisplayEvents: [(date: Date, events: [DisplayEvent])] {
        let upcomingInternal = allEvents.filter { $0.endDate >= Date().startOfDay }
        var dateEventPairs: [(date: Date, event: DisplayEvent)] = []

        for event in upcomingInternal {
            let displayEvent = DisplayEvent(event: event)
            let start = max(event.startDate.startOfDay, Date().startOfDay)
            let end = event.endDate.startOfDay
            var day = start
            while day <= end {
                dateEventPairs.append((date: day, event: displayEvent))
                guard let next = Calendar.current.date(byAdding: .day, value: 1, to: day) else { break }
                day = next
            }
        }

        // External EventKit events (respects disabled calendar filter)
        let externalEvents = ekManager.ekEvents
            .filter { event in
                guard let endDate = event.endDate else { return false }
                guard endDate >= Date().startOfDay else { return false }
                return !ekManager.disabledCalendarIDs.contains(event.calendar.calendarIdentifier)
            }
        for ekEvent in externalEvents {
            let displayEvent = DisplayEvent(ekEvent: ekEvent)
            let start = max(ekEvent.startDate.startOfDay, Date().startOfDay)
            let end = ekEvent.endDate.startOfDay
            var day = start
            while day <= end {
                dateEventPairs.append((date: day, event: displayEvent))
                guard let next = Calendar.current.date(byAdding: .day, value: 1, to: day) else { break }
                day = next
            }
        }

        let grouped = Dictionary(grouping: dateEventPairs) { $0.date }
        return grouped
            .map { (date: $0.key, events: $0.value.map(\.event).sorted { a, b in
                if a.isAllDay && !b.isAllDay { return true }
                if !a.isAllDay && b.isAllDay { return false }
                return a.startDate < b.startDate
            }) }
            .sorted { $0.date < $1.date }
    }
}

struct AgendaDisplayEventRow: View {
    let event: DisplayEvent

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(event.color)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(event.title)
                        .font(.body.weight(.medium))
                    if event.isExternal {
                        Image(systemName: "apple.logo")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                            .accessibilityLabel("Apple Kalender")
                    }
                }

                HStack(spacing: 8) {
                    if event.isAllDay {
                        Label("Hele dagen", systemImage: "sun.max")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Label(
                            "\(event.startDate.timeString) – \(event.endDate.timeString)",
                            systemImage: "clock"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }

                    if !event.location.isEmpty {
                        Label(event.location, systemImage: "location")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    if event.attendeeCount > 0 {
                        Label("\(event.attendeeCount)", systemImage: "person.2")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Text(event.calendarName)
                .font(.system(size: 9))
                .foregroundStyle(event.color)

            if !event.isExternal {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}
