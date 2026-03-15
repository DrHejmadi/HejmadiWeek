import Foundation
import SwiftData
import SwiftUI

@Model
final class CalendarCategory {
    var id: UUID = UUID()
    var name: String = ""
    var colorHex: String = "#4A90D9"
    var iconName: String = "calendar"
    var sortOrder: Int = 0
    var isShared: Bool = false

    @Relationship(deleteRule: .nullify, inverse: \CalendarEvent.category)
    var events: [CalendarEvent]?

    @Relationship(deleteRule: .nullify, inverse: \TodoItem.category)
    var todos: [TodoItem]?

    init(
        name: String,
        colorHex: String,
        iconName: String,
        sortOrder: Int,
        isShared: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
        self.iconName = iconName
        self.sortOrder = sortOrder
        self.isShared = isShared
    }

    var color: Color {
        Color(hex: colorHex) ?? .blue
    }

    static func seedDefaults(in context: ModelContext) {
        let defaults: [(String, String, String, Int, Bool)] = [
            ("Personlig", "#4A90D9", "person.fill", 0, false),
            ("Par", "#E84393", "heart.fill", 1, true),
            ("Madplan", "#00B894", "fork.knife", 2, true),
            ("Børn", "#FDCB6E", "figure.2.and.child.holdinghands", 3, true)
        ]
        for (name, color, icon, order, shared) in defaults {
            let cat = CalendarCategory(
                name: name,
                colorHex: color,
                iconName: icon,
                sortOrder: order,
                isShared: shared
            )
            context.insert(cat)
        }
    }
}
