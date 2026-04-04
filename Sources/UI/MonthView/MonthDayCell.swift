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
    var maxVisibleEvents: Int = 3

    private var allDisplayEvents: [DisplayEvent] {
        if !displayEvents.isEmpty { return displayEvents }
        return events.map { DisplayEvent(event: $0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Day number — compact 20pt circle, left-aligned
            HStack(spacing: 0) {
                Text("\(date.dayOfMonth)")
                    .font(.system(size: 11, weight: isToday ? .bold : .medium))
                    .foregroundStyle(dayNumberColor)
                    .frame(width: 20, height: 20)
                    .background {
                        if isToday {
                            Circle().fill(Color.accentColor)
                        } else if isSelected {
                            Circle().strokeBorder(Color.accentColor, lineWidth: 1)
                        }
                    }
                Spacer(minLength: 0)
            }

            // Event indicators
            if !allDisplayEvents.isEmpty && (isCurrentMonth || showEventsOutsideMonth) {
                eventIndicators
                    .opacity(isCurrentMonth ? 1.0 : 0.4)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .padding(.vertical, 1)
        .padding(.horizontal, 1)
        .background(cellBackground)
        .clipShape(RoundedRectangle(cornerRadius: 3))
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
        HStack(spacing: 1.5) {
            ForEach(allDisplayEvents.prefix(6)) { event in
                Circle()
                    .fill(event.color)
                    .frame(width: 3.5, height: 3.5)
            }
            if allDisplayEvents.count > 6 {
                Text("+\(allDisplayEvents.count - 6)")
                    .font(.system(size: 5))
                    .foregroundStyle(.secondary)
            }
        }
    }

    // Mode: Colored bars
    private var barsMode: some View {
        VStack(spacing: 0.5) {
            ForEach(allDisplayEvents.prefix(maxVisibleEvents)) { event in
                RoundedRectangle(cornerRadius: 0.5)
                    .fill(event.color)
                    .frame(height: 2.5)
            }
            if allDisplayEvents.count > maxVisibleEvents {
                Text("+\(allDisplayEvents.count - maxVisibleEvents)")
                    .font(.system(size: 5))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 1)
    }

    // Mode: Time + title with colored left edge
    private var titlesMode: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(allDisplayEvents.prefix(maxVisibleEvents)) { event in
                HStack(spacing: 0) {
                    // Colored left edge instead of dot — saves ~5pt width
                    RoundedRectangle(cornerRadius: 0.5)
                        .fill(event.color)
                        .frame(width: 2, height: 9)

                    // Time prefix (HH) + title
                    Text(eventLabel(event))
                        .font(.system(size: 7))
                        .lineLimit(1)
                        .foregroundStyle(.primary.opacity(0.7))
                        .padding(.leading, 1)
                }
            }
            if allDisplayEvents.count > maxVisibleEvents {
                Text("+\(allDisplayEvents.count - maxVisibleEvents)")
                    .font(.system(size: 6))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 1)
    }

    private func eventLabel(_ event: DisplayEvent) -> String {
        if event.isAllDay {
            return event.title
        }
        let hour = Calendar.current.component(.hour, from: event.startDate)
        let min = Calendar.current.component(.minute, from: event.startDate)
        let timeStr = min == 0 ? "\(hour)" : String(format: "%d:%02d", hour, min)
        return "\(timeStr) \(event.title)"
    }
}
