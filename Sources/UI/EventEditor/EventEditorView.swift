import SwiftUI
import SwiftData

struct EventEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \CalendarCategory.sortOrder) private var categories: [CalendarCategory]

    var existingEvent: CalendarEvent?
    var initialDate: Date

    @State private var title = ""
    @State private var notes = ""
    @State private var location = ""
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var isAllDay = false
    @State private var selectedCategory: CalendarCategory?
    @State private var alertMinutes: Int = 15
    @State private var createTodo = false
    @State private var todoTitle = ""
    @State private var nlInput = ""

    init(initialDate: Date = Date(), existingEvent: CalendarEvent? = nil) {
        self.initialDate = initialDate
        self.existingEvent = existingEvent

        let nextHour = (Calendar.current.component(.hour, from: Date()) + 1) % 24
        let start = existingEvent?.startDate ?? Calendar.current.date(
            bySettingHour: nextHour,
            minute: 0,
            second: 0,
            of: nextHour == 0 ? Calendar.current.date(byAdding: .day, value: 1, to: initialDate) ?? initialDate : initialDate
        ) ?? initialDate

        let end = existingEvent?.endDate ?? Calendar.current.date(byAdding: .hour, value: 1, to: start) ?? start

        _startDate = State(initialValue: start)
        _endDate = State(initialValue: end)
        _title = State(initialValue: existingEvent?.title ?? "")
        _notes = State(initialValue: existingEvent?.notes ?? "")
        _location = State(initialValue: existingEvent?.location ?? "")
        _isAllDay = State(initialValue: existingEvent?.isAllDay ?? false)
        _alertMinutes = State(initialValue: existingEvent?.alertMinutesBefore ?? 15)
    }

    var body: some View {
        NavigationStack {
            Form {
                nlSection
                detailsSection
                timeSection
                categorySection
                alertSection
                todoSection
            }
            .navigationTitle(existingEvent != nil ? "Rediger" : "Ny begivenhed")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuller") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Gem") { save() }
                        .disabled(title.isEmpty)
                        .fontWeight(.semibold)
                }
            }
            .onAppear {
                if let existing = existingEvent, let cat = existing.category {
                    selectedCategory = cat
                } else if selectedCategory == nil {
                    selectedCategory = categories.first
                }
            }
        }
    }

    // MARK: - Sections

    private var nlSection: some View {
        Section {
            HStack {
                TextField("Fx: Tandlæge fredag kl 14", text: $nlInput)
                    .textFieldStyle(.plain)
                Button("Tilføj") {
                    parseNaturalLanguage()
                }
                .buttonStyle(.borderedProminent)
                .disabled(nlInput.isEmpty)
            }
        } header: {
            Label("Hurtig tilføjelse", systemImage: "text.bubble")
        }
    }

    private var detailsSection: some View {
        Section("Detaljer") {
            TextField("Titel", text: $title)
                .font(.headline)
            TextField("Noter", text: $notes, axis: .vertical)
                .lineLimit(3...6)
            TextField("Lokation", text: $location)
        }
    }

    private var timeSection: some View {
        Section("Tid") {
            Toggle("Hele dagen", isOn: $isAllDay)
            if isAllDay {
                DatePicker("Start", selection: $startDate, displayedComponents: [.date])
                DatePicker("Slut", selection: $endDate, in: startDate..., displayedComponents: [.date])
            } else {
                DatePicker("Start", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                DatePicker("Slut", selection: $endDate, in: startDate..., displayedComponents: [.date, .hourAndMinute])
            }
        }
    }

    private var categorySection: some View {
        Section("Kalender") {
            ForEach(categories) { category in
                categoryRow(category)
            }
        }
    }

    private func categoryRow(_ category: CalendarCategory) -> some View {
        Button {
            selectedCategory = category
        } label: {
            HStack {
                Image(systemName: category.iconName)
                    .foregroundStyle(category.color)
                    .frame(width: 24)
                Text(category.name)
                    .foregroundStyle(.primary)
                Spacer()
                if selectedCategory?.id == category.id {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
    }

    private var alertSection: some View {
        Section("Påmindelse") {
            Picker("Alarm", selection: $alertMinutes) {
                Text("Ingen").tag(0)
                Text("5 minutter").tag(5)
                Text("15 minutter").tag(15)
                Text("30 minutter").tag(30)
                Text("1 time").tag(60)
                Text("1 dag").tag(1440)
            }
        }
    }

    private var todoSection: some View {
        Section("To-Do") {
            Toggle("Opret tilknyttet to-do", isOn: $createTodo)
            if createTodo {
                TextField("To-do titel", text: $todoTitle)
            }
        }
    }

    // MARK: - Actions

    private func save() {
        if let existing = existingEvent {
            existing.title = title
            existing.notes = notes
            existing.location = location
            existing.startDate = startDate
            existing.endDate = endDate
            existing.isAllDay = isAllDay
            existing.category = selectedCategory
            existing.alertMinutesBefore = alertMinutes > 0 ? alertMinutes : nil
            existing.updatedAt = Date()
        } else {
            let event = CalendarEvent(
                title: title,
                notes: notes,
                location: location,
                startDate: startDate,
                endDate: endDate,
                isAllDay: isAllDay,
                category: selectedCategory,
                alertMinutesBefore: alertMinutes > 0 ? alertMinutes : nil
            )
            modelContext.insert(event)

            if createTodo && !todoTitle.isEmpty {
                let todo = TodoItem(
                    title: todoTitle,
                    dueDate: startDate,
                    category: selectedCategory,
                    linkedEvent: event
                )
                modelContext.insert(todo)
            }
        }

        dismiss()
    }

    private func parseNaturalLanguage() {
        let input = nlInput.lowercased()
        var remaining = nlInput
        var parsedDate = startDate

        // Parse relative days: "i morgen", "i overmorgen", "i dag"
        if input.contains("i overmorgen") {
            parsedDate = Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? parsedDate
            remaining = remaining.replacingOccurrences(of: "i overmorgen", with: "", options: .caseInsensitive)
        } else if input.contains("i morgen") {
            parsedDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? parsedDate
            remaining = remaining.replacingOccurrences(of: "i morgen", with: "", options: .caseInsensitive)
        } else if input.contains("i dag") {
            parsedDate = Date()
            remaining = remaining.replacingOccurrences(of: "i dag", with: "", options: .caseInsensitive)
        }

        // Parse Danish weekday names → next occurrence
        let weekdayMap: [(String, Int)] = [
            ("søndag", 1), ("mandag", 2), ("tirsdag", 3), ("onsdag", 4),
            ("torsdag", 5), ("fredag", 6), ("lørdag", 7)
        ]
        for (name, weekday) in weekdayMap {
            if input.contains(name) {
                parsedDate = nextDate(weekday: weekday, from: Date())
                remaining = remaining.replacingOccurrences(of: name, with: "", options: .caseInsensitive)
                break
            }
        }

        // Parse time: "kl 14", "kl. 9:30", "kl 14-16"
        let timeRangePattern = /kl\.?\s*(\d{1,2})[:\.]?(\d{2})?\s*[-–]\s*(\d{1,2})[:\.]?(\d{2})?/
        let timePattern = /kl\.?\s*(\d{1,2})[:\.]?(\d{2})?/

        if let match = input.firstMatch(of: timeRangePattern) {
            let startHour = Int(match.1) ?? 9
            let startMin = Int(match.2 ?? "0") ?? 0
            let endHour = Int(match.3) ?? (startHour + 1)
            let endMin = Int(match.4 ?? "0") ?? 0
            if let s = Calendar.current.date(bySettingHour: startHour, minute: startMin, second: 0, of: parsedDate),
               let e = Calendar.current.date(bySettingHour: endHour, minute: endMin, second: 0, of: parsedDate) {
                startDate = s
                endDate = e
            }
            remaining = remaining.replacing(timeRangePattern, with: { _ in "" })
        } else if let match = input.firstMatch(of: timePattern) {
            let hour = Int(match.1) ?? 12
            let minute = Int(match.2 ?? "0") ?? 0
            if let date = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: parsedDate) {
                startDate = date
                endDate = Calendar.current.date(byAdding: .hour, value: 1, to: date) ?? date
            }
            remaining = remaining.replacing(timePattern, with: { _ in "" })
        } else {
            // No time specified — keep date change only
            startDate = parsedDate
            endDate = Calendar.current.date(byAdding: .hour, value: 1, to: parsedDate) ?? parsedDate
        }

        title = remaining.trimmingCharacters(in: .whitespacesAndNewlines)
        if title.isEmpty { title = nlInput }
        nlInput = ""
    }

    private func nextDate(weekday: Int, from date: Date) -> Date {
        let cal = Calendar.current
        let current = cal.component(.weekday, from: date)
        var daysAhead = weekday - current
        if daysAhead <= 0 { daysAhead += 7 }
        return cal.date(byAdding: .day, value: daysAhead, to: date) ?? date
    }
}
