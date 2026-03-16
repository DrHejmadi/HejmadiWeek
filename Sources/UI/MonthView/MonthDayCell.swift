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
        VStack(spacing: 3) {
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

            // WeekCal-style dots
            if !allDisplayEvents.isEmpty {
                eventDots
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
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
            } else {
                Color.clear
            }
        }
    }

    // MARK: - Event Dots (WeekCal style)

    private var eventDots: some View {
        let maxDots = 4
        let visibleEvents = Array(allDisplayEvents.prefix(maxDots))
        let hasMore = allDisplayEvents.count > maxDots

        return HStack(spacing: 3) {
            ForEach(visibleEvents) { event in
                Circle()
                    .fill(event.color)
                    .frame(width: 5, height: 5)
            }
            if hasMore {
                Circle()
                    .fill(Color.secondary.opacity(0.4))
                    .frame(width: 5, height: 5)
            }
        }
    }
}
