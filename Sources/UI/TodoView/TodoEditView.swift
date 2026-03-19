import SwiftUI
import SwiftData

struct TodoEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var todo: TodoItem
    let categories: [CalendarCategory]

    @State private var title: String
    @State private var notes: String
    @State private var dueDate: Date
    @State private var hasDueDate: Bool
    @State private var priority: Int
    @State private var selectedCategory: CalendarCategory?
    @State private var addToCalendar: Bool
    @State private var calendarDate: Date

    init(todo: TodoItem, categories: [CalendarCategory]) {
        self.todo = todo
        self.categories = categories
        _title = State(initialValue: todo.title)
        _notes = State(initialValue: todo.notes)
        _dueDate = State(initialValue: todo.dueDate ?? Date())
        _hasDueDate = State(initialValue: todo.dueDate != nil)
        _priority = State(initialValue: todo.priority)
        _selectedCategory = State(initialValue: todo.category)
        _addToCalendar = State(initialValue: false)
        _calendarDate = State(initialValue: todo.dueDate ?? Date())
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Detaljer") {
                    TextField("Titel", text: $title)
                        .font(.headline)
                    TextField("Noter", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Dato") {
                    Toggle("Har deadline", isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker("Dato", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }

                Section("Prioritet") {
                    Picker("Prioritet", selection: $priority) {
                        Text("Ingen").tag(0)
                        Text("Lav").tag(1)
                        Text("Medium").tag(2)
                        Text("Høj").tag(3)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Kalender") {
                    ForEach(categories) { category in
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
                }

                if todo.linkedEvent == nil {
                    Section("Tilføj til kalender") {
                        Toggle("Opret kalenderbegivenhed", isOn: $addToCalendar)
                        if addToCalendar {
                            DatePicker("Tidspunkt", selection: $calendarDate, displayedComponents: [.date, .hourAndMinute])
                        }
                    }
                } else {
                    Section("Tilknyttet begivenhed") {
                        HStack {
                            Image(systemName: "link")
                                .foregroundStyle(.secondary)
                            Text(todo.linkedEvent?.title ?? "")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Rediger opgave")
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
        }
    }

    private func save() {
        todo.title = title
        todo.notes = notes
        todo.dueDate = hasDueDate ? dueDate : nil
        todo.priority = priority
        todo.category = selectedCategory
        todo.updatedAt = Date()

        if addToCalendar && todo.linkedEvent == nil {
            let event = CalendarEvent(
                title: title,
                notes: notes,
                startDate: calendarDate,
                endDate: Calendar.current.date(byAdding: .hour, value: 1, to: calendarDate) ?? calendarDate,
                category: selectedCategory
            )
            modelContext.insert(event)
            todo.linkedEvent = event
        }

        dismiss()
    }
}
