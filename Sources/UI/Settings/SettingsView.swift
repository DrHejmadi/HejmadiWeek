import SwiftUI
import SwiftData
import EventKit

enum DayCellMode: String, CaseIterable {
    case dots = "Prikker"
    case titles = "Titler"
    case bars = "Farvebjælker"
}

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CalendarCategory.sortOrder) private var categories: [CalendarCategory]
    @AppStorage("weekStartsOnMonday") private var weekStartsOnMonday = true
    @AppStorage("showWeekNumbers") private var showWeekNumbers = true
    @AppStorage("defaultView") private var defaultView = "month"
    @AppStorage("defaultAlertMinutes") private var defaultAlertMinutes = 15
    @AppStorage("dayCellMode") private var dayCellMode = "titles"
    @AppStorage("showHeatmap") private var showHeatmap = true
    @State private var ekManager = EventKitManager.shared

    var body: some View {
        Form {
            Section("Kalendere") {
                ForEach(categories) { category in
                    HStack {
                        Image(systemName: category.iconName)
                            .foregroundStyle(category.color)
                            .frame(width: 24)
                        Text(category.name)
                        Spacer()
                        if category.isShared {
                            Image(systemName: "person.2")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if ekManager.isAuthorized {
                    ForEach(ekManager.ekCalendars, id: \.calendarIdentifier) { cal in
                        HStack {
                            Circle()
                                .fill(Color(cgColor: cal.cgColor))
                                .frame(width: 10, height: 10)
                            Text(cal.title)
                            Spacer()
                            Image(systemName: "apple.logo")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Toggle("", isOn: Binding(
                                get: { ekManager.isCalendarEnabled(cal.calendarIdentifier) },
                                set: { _ in ekManager.toggleCalendar(cal.calendarIdentifier) }
                            ))
                            .labelsHidden()
                        }
                    }
                } else {
                    Button {
                        Task { await ekManager.requestAccess() }
                    } label: {
                        Label("Giv adgang til Apple Kalender", systemImage: "calendar.badge.plus")
                    }
                }
            }

            Section("Månedsvisning") {
                Picker("Dagcelle-visning", selection: $dayCellMode) {
                    ForEach(DayCellMode.allCases, id: \.rawValue) { mode in
                        Text(mode.rawValue).tag(mode.rawValue)
                    }
                }
                Toggle("Vis heatmap (travlhed)", isOn: $showHeatmap)
            }

            Section("Visning") {
                Toggle("Uge starter mandag", isOn: $weekStartsOnMonday)
                Toggle("Vis ugenumre", isOn: $showWeekNumbers)

                Picker("Standard visning", selection: $defaultView) {
                    Text("Måned").tag("month")
                    Text("Uge").tag("week")
                    Text("Agenda").tag("agenda")
                }
            }

            Section("Påmindelser") {
                Picker("Standard alarm", selection: $defaultAlertMinutes) {
                    Text("Ingen").tag(0)
                    Text("5 minutter").tag(5)
                    Text("15 minutter").tag(15)
                    Text("30 minutter").tag(30)
                    Text("1 time").tag(60)
                }
            }

            Section("Om") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"))")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Udvikler")
                    Spacer()
                    Text("Hejmadi")
                        .foregroundStyle(.secondary)
                }
            }
        }
        #if os(macOS)
        .formStyle(.grouped)
        .frame(minWidth: 400, minHeight: 300)
        #endif
        .onAppear {
            if ekManager.isAuthorized {
                ekManager.fetchEventsForMonth(containing: Date())
            }
        }
    }
}

// Placeholder for macOS menu bar
struct MenuBarView: View {
    @Query(sort: \CalendarEvent.startDate) private var events: [CalendarEvent]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("I dag")
                .font(.headline)
                .padding(.horizontal)

            let todayEvents = events.filter { $0.startDate.isToday }

            if todayEvents.isEmpty {
                Text("Ingen begivenheder i dag")
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                ForEach(todayEvents.prefix(5), id: \.id) { event in
                    HStack {
                        Circle()
                            .fill(event.category?.color ?? .blue)
                            .frame(width: 6, height: 6)
                        Text(event.isAllDay ? "Hele dagen" : event.startDate.timeString)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 50, alignment: .leading)
                        Text(event.title)
                            .lineLimit(1)
                    }
                    .padding(.horizontal)
                }
            }

            Divider()
            Button("Åbn HejmadiWeek") {
                #if os(macOS)
                NSApp.activate()
                #endif
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .frame(width: 250)
    }
}
