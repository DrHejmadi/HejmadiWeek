import SwiftUI

struct MonthDayCell: View {
    let date: Date
    let isCurrentMonth: Bool
    let isSelected: Bool
    let isToday: Bool
    let events: [CalendarEvent]
    let categories: [CalendarCategory]
    var displayEvents: [DisplayEvent] = []
    var dayCellMode: String = "titles"
    var showHeatmap: Bool = true
    var showEventsOutsideMonth: Bool = false

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

            // Event indicators — show for all days (including prev/next month)
            if !allDisplayEvents.isEmpty && (isCurrentMonth || showEventsOutsideMonth) {
                eventIndicators
                    .opacity(isCurrentMonth ? 1.0 : 0.4)
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

    // MARK: - Cell Background (Heatmap)

    private var cellBackground: some View {
        Group {
            if isSelected {
                Color.accentColor.opacity(0.08)
            } else if isCurrentMonth && showHeatmap {
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

    // MARK: - Event Indicators (configurable mode)

    @ViewBuilder
    private var eventIndicators: some View {
        switch dayCellMode {
        case "dots":
            dotsMode
        case "bars":
            barsMode
        case "titles":
            titlesMode
        default:
            titlesMode
        }
    }

    // Mode: Colored dots only
    private var dotsMode: some View {
        HStack(spacing: 2) {
            ForEach(allDisplayEvents.prefix(5)) { event in
                Circle()
                    .fill(event.color)
                    .frame(width: 4, height: 4)
            }
            if allDisplayEvents.count > 5 {
                Text("+\(allDisplayEvents.count - 5)")
                    .font(.system(size: 5))
                    .foregroundStyle(.secondary)
            }
        }
    }

    // Mode: Colored bars
    private var barsMode: some View {
        VStack(spacing: 1) {
            ForEach(allDisplayEvents.prefix(4)) { event in
                RoundedRectangle(cornerRadius: 1)
                    .fill(event.color)
                    .frame(height: 3)
            }
            if allDisplayEvents.count > 4 {
                Text("+\(allDisplayEvents.count - 4)")
                    .font(.system(size: 5))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 2)
    }

    // Mode: Event titles with dots
    private var titlesMode: some View {
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
