import Foundation
import SwiftData

@Model
final class TodoItem {

    var id: UUID = UUID()
    var title: String = ""
    var notes: String = ""
    var dueDate: Date?
    var isCompleted: Bool = false
    var completedAt: Date?
    var priority: Int = 0
    var sortOrder: Int = 0
    var isShared: Bool = false
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    @Relationship(deleteRule: .nullify)
    var category: CalendarCategory?

    @Relationship(deleteRule: .nullify)
    var linkedEvent: CalendarEvent?

    init(
        title: String,
        notes: String = "",
        dueDate: Date? = nil,
        isCompleted: Bool = false,
        priority: Int = 0,
        sortOrder: Int = 0,
        isShared: Bool = false,
        category: CalendarCategory? = nil,
        linkedEvent: CalendarEvent? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.notes = notes
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.priority = priority
        self.sortOrder = sortOrder
        self.isShared = isShared
        self.category = category
        self.linkedEvent = linkedEvent
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    func toggleCompleted() {
        isCompleted.toggle()
        completedAt = isCompleted ? Date() : nil
        updatedAt = Date()
    }

    var priorityLabel: String {
        switch priority {
        case 3: return "Høj"
        case 2: return "Medium"
        case 1: return "Lav"
        default: return "Ingen"
        }
    }
}
