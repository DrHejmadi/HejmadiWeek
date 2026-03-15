import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query(sort: \CalendarCategory.sortOrder) private var categories: [CalendarCategory]
    @AppStorage("weekStartsOnMonday") private var weekStartsOnMonday = true
    @AppStorage("showWeekNumbers") private var showWeekNumbers = true
    @AppStorage("defaultView") private var defaultView = "month"
    @AppStorage("defaultAlertMinutes") private var defaultAlertMinutes = 15

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
                    Text("1.0.0")
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
                NSApp.activate(ignoringOtherApps: true)
                #endif
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .frame(width: 250)
    }
}
