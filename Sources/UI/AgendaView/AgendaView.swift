import SwiftUI
import SwiftData

struct AgendaView: View {
    @Query(sort: \CalendarEvent.startDate) private var allEvents: [CalendarEvent]
    @State private var showEventEditor = false

    var body: some View {
        List {
            ForEach(groupedEvents, id: \.date) { group in
                Section {
                    ForEach(group.events, id: \.id) { event in
                        AgendaEventRow(event: event)
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

            if groupedEvents.isEmpty {
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
                Button { showEventEditor = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showEventEditor) {
            EventEditorView()
        }
    }

    private var groupedEvents: [(date: Date, events: [CalendarEvent])] {
        let upcoming = allEvents.filter { $0.endDate >= Date().startOfDay }
        let grouped = Dictionary(grouping: upcoming) { event in
            event.startDate.startOfDay
        }
        return grouped
            .map { (date: $0.key, events: $0.value.sorted { $0.startDate < $1.startDate }) }
            .sorted { $0.date < $1.date }
    }
}

struct AgendaEventRow: View {
    let event: CalendarEvent

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(event.category?.color ?? .blue)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.body.weight(.medium))

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
                }
            }

            Spacer()

            if let cat = event.category {
                Image(systemName: cat.iconName)
                    .foregroundStyle(cat.color)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
}
