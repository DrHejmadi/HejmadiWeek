import SwiftUI
import SwiftData

enum TodoSortOrder: String, CaseIterable {
    case dueDate = "Dato"
    case priority = "Prioritet"
    case category = "Kalender"
    case created = "Oprettet"
}

struct TodoListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TodoItem.dueDate) private var allTodos: [TodoItem]
    @Query(sort: \CalendarCategory.sortOrder) private var categories: [CalendarCategory]

    @State private var sortOrder: TodoSortOrder = .dueDate
    @State private var filterCategory: CalendarCategory?
    @State private var showCompleted = false
    @State private var newTodoTitle = ""
    @State private var editingTodo: TodoItem?
    @State private var recentlyDeleted: TodoItem?
    @State private var showUndoBanner = false

    var body: some View {
        VStack(spacing: 0) {
            filterBar
            quickAddBar

            List {
                if !pendingTodos.isEmpty {
                    Section("Opgaver (\(pendingTodos.count))") {
                        ForEach(pendingTodos) { todo in
                            TodoRowView(todo: todo)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editingTodo = todo
                                }
                        }
                        .onDelete(perform: deleteTodos)
                    }
                }

                if showCompleted && !completedTodos.isEmpty {
                    Section("Fuldført (\(completedTodos.count))") {
                        ForEach(completedTodos) { todo in
                            TodoRowView(todo: todo)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editingTodo = todo
                                }
                        }
                        .onDelete(perform: deleteCompletedTodos)
                    }
                }

                if !showCompleted && !completedTodos.isEmpty {
                    Section {
                        Button {
                            withAnimation { showCompleted = true }
                        } label: {
                            HStack {
                                Image(systemName: "eye")
                                    .font(.caption)
                                Text("Vis \(completedTodos.count) fuldførte opgaver")
                                    .font(.subheadline)
                            }
                            .foregroundStyle(.secondary)
                        }
                    }
                }

                if pendingTodos.isEmpty && (!showCompleted || completedTodos.isEmpty) {
                    ContentUnavailableView(
                        "Ingen opgaver",
                        systemImage: "checklist",
                        description: Text("Tilføj en ny opgave ovenfor")
                    )
                }
            }
            #if os(iOS)
            .listStyle(.insetGrouped)
            #endif
        }
        .overlay(alignment: .top) {
            if showUndoBanner {
                undoBanner
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Toggle("Vis fuldførte", isOn: $showCompleted)
                    Divider()
                    Picker("Sortering", selection: $sortOrder) {
                        ForEach(TodoSortOrder.allCases, id: \.self) { order in
                            Text(order.rawValue).tag(order)
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }
        .sheet(item: $editingTodo) { todo in
            TodoEditView(todo: todo, categories: categories)
        }
    }

    // MARK: - Undo Banner

    private var undoBanner: some View {
        HStack {
            Image(systemName: "trash")
                .font(.caption)
            Text("Opgave slettet")
                .font(.subheadline)
            Spacer()
            Button("Fortryd") {
                undoDelete()
            }
            .font(.subheadline.weight(.semibold))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
        .padding(.horizontal)
        .padding(.top, 4)
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: "Alle",
                    isSelected: filterCategory == nil,
                    action: { filterCategory = nil }
                )

                ForEach(categories) { cat in
                    FilterChip(
                        title: cat.name,
                        icon: cat.iconName,
                        color: cat.color,
                        isSelected: filterCategory?.id == cat.id,
                        action: { filterCategory = filterCategory?.id == cat.id ? nil : cat }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Quick Add

    private var quickAddBar: some View {
        HStack(spacing: 8) {
            TextField("Ny opgave...", text: $newTodoTitle)
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.secondary.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .onSubmit { addQuickTodo() }

            Button(action: addQuickTodo) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
            }
            .disabled(newTodoTitle.isEmpty)
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    // MARK: - Sorted/Filtered Todos

    private var pendingTodos: [TodoItem] {
        sortAndFilter(allTodos.filter { !$0.isCompleted })
    }

    private var completedTodos: [TodoItem] {
        sortAndFilter(allTodos.filter { $0.isCompleted })
    }

    private func sortAndFilter(_ todos: [TodoItem]) -> [TodoItem] {
        var filtered = todos
        if let cat = filterCategory {
            filtered = filtered.filter { $0.category?.id == cat.id }
        }

        switch sortOrder {
        case .dueDate:
            return filtered.sorted {
                let d0 = $0.linkedEvent?.startDate ?? $0.dueDate ?? .distantFuture
                let d1 = $1.linkedEvent?.startDate ?? $1.dueDate ?? .distantFuture
                return d0 < d1
            }
        case .priority:
            return filtered.sorted { $0.priority > $1.priority }
        case .category:
            return filtered.sorted {
                ($0.category?.sortOrder ?? 99) < ($1.category?.sortOrder ?? 99)
            }
        case .created:
            return filtered.sorted { $0.createdAt > $1.createdAt }
        }
    }

    // MARK: - Actions

    private func addQuickTodo() {
        guard !newTodoTitle.isEmpty else { return }
        let todo = TodoItem(
            title: newTodoTitle,
            dueDate: Date(),
            category: filterCategory ?? categories.first
        )
        modelContext.insert(todo)
        newTodoTitle = ""
    }

    private func deleteTodos(at offsets: IndexSet) {
        let todosToDelete = offsets.map { pendingTodos[$0] }
        for todo in todosToDelete {
            // Keep the last deleted for undo
            recentlyDeleted = TodoItem(
                title: todo.title,
                notes: todo.notes,
                dueDate: todo.dueDate,
                isCompleted: todo.isCompleted,
                priority: todo.priority,
                category: todo.category
            )
            modelContext.delete(todo)
        }
        withAnimation { showUndoBanner = true }
        // Auto-hide after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            withAnimation { showUndoBanner = false }
        }
    }

    private func deleteCompletedTodos(at offsets: IndexSet) {
        let todosToDelete = offsets.map { completedTodos[$0] }
        for todo in todosToDelete {
            recentlyDeleted = TodoItem(
                title: todo.title,
                notes: todo.notes,
                dueDate: todo.dueDate,
                isCompleted: todo.isCompleted,
                priority: todo.priority,
                category: todo.category
            )
            modelContext.delete(todo)
        }
        withAnimation { showUndoBanner = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            withAnimation { showUndoBanner = false }
        }
    }

    private func undoDelete() {
        if let deleted = recentlyDeleted {
            modelContext.insert(deleted)
            recentlyDeleted = nil
        }
        withAnimation { showUndoBanner = false }
    }
}

// MARK: - TodoRowView

struct TodoRowView: View {
    @Bindable var todo: TodoItem

    var body: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    todo.toggleCompleted()
                }
            } label: {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(todo.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(todo.title)
                    .strikethrough(todo.isCompleted)
                    .foregroundStyle(todo.isCompleted ? .secondary : .primary)

                HStack(spacing: 6) {
                    if let dueDate = todo.dueDate {
                        Label(dueDate.formatted(.dateTime.day().month(.abbreviated)), systemImage: "calendar")
                            .font(.caption)
                            .foregroundStyle(dueDate < Date() && !todo.isCompleted ? .red : .secondary)
                    }

                    if let category = todo.category {
                        Label(category.name, systemImage: category.iconName)
                            .font(.caption)
                            .foregroundStyle(category.color)
                    }

                    if todo.linkedEvent != nil {
                        Image(systemName: "link")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            if todo.priority > 0 {
                priorityIndicator
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 2)
    }

    private var priorityIndicator: some View {
        HStack(spacing: 1) {
            ForEach(0..<todo.priority, id: \.self) { _ in
                Image(systemName: "exclamationmark")
                    .font(.system(size: 8, weight: .bold))
            }
        }
        .foregroundStyle(todo.priority == 3 ? .red : todo.priority == 2 ? .orange : .blue)
    }
}

// MARK: - TodoEditView

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

// MARK: - FilterChip

struct FilterChip: View {
    let title: String
    var icon: String? = nil
    var color: Color = .accentColor
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.caption.weight(.medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? color.opacity(0.15) : Color.secondary.opacity(0.12))
            .foregroundStyle(isSelected ? color : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
