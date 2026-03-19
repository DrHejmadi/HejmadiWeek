import SwiftUI
import SwiftData

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
