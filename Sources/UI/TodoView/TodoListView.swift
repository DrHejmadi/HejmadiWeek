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

            Button("Tilføj opgave", systemImage: "plus.circle.fill", action: addQuickTodo)
                .labelStyle(.iconOnly)
                .font(.title2)
                .symbolRenderingMode(.hierarchical)
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
        performDelete(todosToDelete)
    }

    private func deleteCompletedTodos(at offsets: IndexSet) {
        let todosToDelete = offsets.map { completedTodos[$0] }
        performDelete(todosToDelete)
    }

    private func performDelete(_ todos: [TodoItem]) {
        for todo in todos {
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
        Task {
            try? await Task.sleep(for: .seconds(5))
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
