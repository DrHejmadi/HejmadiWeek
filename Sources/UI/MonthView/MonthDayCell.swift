import SwiftUI

struct MonthDayCell: View {
    let date: Date
    let isCurrentMonth: Bool
    let isSelected: Bool
    let isToday: Bool
    let events: [CalendarEvent]
    let categories: [CalendarCategory]

    private let maxVisibleEvents = 3

    var body: some View {
        VStack(spacing: 2) {
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

            // Event indicators
            if !events.isEmpty {
                eventIndicators
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 64)
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

    // MARK: - Cell Background (Heatmap)

    private var cellBackground: some View {
        Group {
            if isSelected {
                Color.accentColor.opacity(0.08)
            } else if !isCurrentMonth {
                Color.clear
            } else {
                heatmapColor
            }
        }
    }

    private var heatmapColor: Color {
        let count = events.count
        switch count {
        case 0: return .clear
        case 1: return Color.green.opacity(0.06)
        case 2: return Color.yellow.opacity(0.06)
        case 3: return Color.orange.opacity(0.06)
        default: return Color.red.opacity(0.08)
        }
    }

    // MARK: - Event Indicators

    @ViewBuilder
    private var eventIndicators: some View {
        let visibleEvents = Array(events.prefix(maxVisibleEvents))
        let overflow = events.count - maxVisibleEvents

        VStack(spacing: 1) {
            ForEach(visibleEvents, id: \.id) { event in
                eventChip(for: event)
            }

            if overflow > 0 {
                Text("+\(overflow)")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func eventChip(for event: CalendarEvent) -> some View {
        HStack(spacing: 2) {
            Circle()
                .fill(event.category?.color ?? .blue)
                .frame(width: 4, height: 4)

            if event.isAllDay {
                Text(event.title)
                    .font(.system(size: 8, weight: .medium))
                    .lineLimit(1)
            } else {
                Text(event.startDate.timeString)
                    .font(.system(size: 7))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 2)
    }
}
