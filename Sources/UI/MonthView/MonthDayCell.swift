import SwiftUI

struct MonthDayCell: View {
    let date: Date
    let isCurrentMonth: Bool
    let isSelected: Bool
    let isToday: Bool
    let events: [CalendarEvent]
    let categories: [CalendarCategory]
    var displayEvents: [DisplayEvent] = []

    private var allDisplayEvents: [DisplayEvent] {
        if !displayEvents.isEmpty { return displayEvents }
        return events.map { DisplayEvent(event: $0) }
    }

    var body: some View {
        VStack(spacing: 1) {
            // Day number
            Text("\(date.dayOfMonth)")
                .font(.system(size: 14, weight: isToday ? .bold : .medium))
                .foregroundStyle(dayNumberColor)
                .frame(width: 26, height: 26)
                .background {
                    if isToday {
                        Circle().fill(Color.accentColor)
                    } else if isSelected {
                        Circle().strokeBorder(Color.accentColor, lineWidth: 1.5)
                    }
                }

            // Event titles as small text
            if !allDisplayEvents.isEmpty && isCurrentMonth {
                eventTitles
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .padding(.vertical, 2)
        .background(cellBackground)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    // MARK: - Day Number Color

    private var dayNumberColor: Color {
        if isToday {
            return .white
        } else if !isCurrentMonth {
            return .secondary.opacity(0.4)
        } else if date.isWeekend {
            return .secondary
        } else {
            return .primary
        }
    }

    // MARK: - Cell Background

    private var cellBackground: some View {
        Group {
            if isSelected {
                Color.accentColor.opacity(0.08)
            } else if isCurrentMonth {
                let count = allDisplayEvents.count
                if count >= 5 {
                    Color.blue.opacity(0.12)
                } else if count >= 3 {
                    Color.blue.opacity(0.07)
                } else if count >= 1 {
                    Color.blue.opacity(0.03)
                } else {
                    Color.clear
                }
            } else {
                Color.clear
            }
        }
    }

    // MARK: - Event Titles

    private var eventTitles: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(allDisplayEvents.prefix(3)) { event in
                HStack(spacing: 2) {
                    Circle()
                        .fill(event.color)
                        .frame(width: 4, height: 4)
                    Text(event.title)
                        .font(.system(size: 7))
                        .lineLimit(1)
                        .foregroundStyle(.primary.opacity(0.7))
                }
            }
            if allDisplayEvents.count > 3 {
                Text("+\(allDisplayEvents.count - 3)")
                    .font(.system(size: 6))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 2)
    }
}
