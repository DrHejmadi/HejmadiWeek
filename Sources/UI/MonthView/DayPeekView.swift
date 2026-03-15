import SwiftUI

struct DayPeekView: View {
    let date: Date
    let events: [CalendarEvent]
    let onClose: () -> Void
    let onAddEvent: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            Capsule()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 36, height: 4)
                .padding(.top, 8)

            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(date.formatted(.dateTime.weekday(.wide).locale(Locale(identifier: "da_DK"))))
                        .font(.headline)
                    Text(date.formatted(.dateTime.day().month(.wide).locale(Locale(identifier: "da_DK"))))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(action: onAddEvent) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .symbolRenderingMode(.hierarchical)
                }

                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)

            Divider()
                .padding(.top, 8)

            // Events list
            if events.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.largeTitle)
                        .foregroundStyle(.tertiary)
                    Text("Ingen begivenheder")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                ScrollView {
                    LazyVStack(spacing: 6) {
                        ForEach(sortedEvents, id: \.id) { event in
                            DayPeekEventRow(event: event)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .frame(maxHeight: 200)
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 10, y: -2)
        .padding(.horizontal, 4)
    }

    private var sortedEvents: [CalendarEvent] {
        events.sorted { a, b in
            if a.isAllDay && !b.isAllDay { return true }
            if !a.isAllDay && b.isAllDay { return false }
            return a.startDate < b.startDate
        }
    }
}

struct DayPeekEventRow: View {
    let event: CalendarEvent

    var body: some View {
        HStack(spacing: 10) {
            // Color bar
            RoundedRectangle(cornerRadius: 2)
                .fill(event.category?.color ?? .blue)
                .frame(width: 4, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)

                HStack(spacing: 4) {
                    if event.isAllDay {
                        Text("Hele dagen")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("\(event.startDate.timeString) – \(event.endDate.timeString)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if !event.location.isEmpty {
                        Image(systemName: "location.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(.secondary)
                        Text(event.location)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            if let category = event.category {
                Image(systemName: category.iconName)
                    .font(.caption)
                    .foregroundStyle(category.color)
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Color(.systemBackground).opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
