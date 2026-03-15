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

    @State private var showAddTodo = false
    @State private var sortOrder: TodoSortOrder = .dueDate
    @State private var filterCategory: CalendarCategory?
    @State private var showCompleted = false
    @State private var newTodoTitle = ""

    var body: some View {
        VStack(spacing: 0) {
            // Filter & Sort bar
            filterBar

            // Quick add
            quickAddBar

            // Todo list
            List {
                if !pendingTodos.isEmpty {
                    Section("Opgaver (\(pendingTodos.count))") {
                        ForEach(pendingTodos) { todo in
                            TodoRowView(todo: todo)
                        }
                        .onDelete(perform: deleteTodos)
                    }
                }

                if showCompleted && !completedTodos.isEmpty {
                    Section("Fuldført (\(completedTodos.count))") {
                        ForEach(completedTodos) { todo in
                            TodoRowView(todo: todo)
                        }
                        .onDelete(perform: deleteCompletedTodos)
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
                ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture)
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
        for index in offsets {
            modelContext.delete(pendingTodos[index])
        }
    }

    private func deleteCompletedTodos(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(completedTodos[index])
        }
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
