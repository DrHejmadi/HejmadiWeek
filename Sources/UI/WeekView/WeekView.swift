import SwiftUI
import SwiftData

struct WeekView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CalendarEvent.startDate) private var allEvents: [CalendarEvent]

    @State private var currentWeekStart = Date().startOfWeek
    @State private var showEventEditor = false
    @State private var selectedDate = Date()

    private let hours = Array(6...22)

    var body: some View {
        VStack(spacing: 0) {
            weekHeader
            weekDayStrip

            ScrollView {
                timeGrid
            }
        }
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    if value.translation.width < -50 {
                        withAnimation { advanceWeek(by: 1) }
                    } else if value.translation.width > 50 {
                        withAnimation { advanceWeek(by: -1) }
                    }
                }
        )
        .sheet(isPresented: $showEventEditor) {
            EventEditorView(initialDate: selectedDate)
        }
    }

    // MARK: - Header

    private var weekHeader: some View {
        HStack {
            Button { withAnimation { advanceWeek(by: -1) } } label: {
                Image(systemName: "chevron.left")
            }

            Spacer()

            Text("Uge \(currentWeekStart.weekNumber)")
                .font(.headline)

            Spacer()

            Button {
                withAnimation {
                    currentWeekStart = Date().startOfWeek
                }
            } label: {
                Text("I dag")
                    .font(.subheadline.weight(.medium))
            }

            Button { withAnimation { advanceWeek(by: 1) } } label: {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    // MARK: - Day Strip

    private var weekDayStrip: some View {
        HStack(spacing: 0) {
            Text("")
                .frame(width: 44)

            ForEach(weekDates, id: \.self) { date in
                VStack(spacing: 2) {
                    Text(date.shortDayName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(date.dayOfMonth)")
                        .font(.system(size: 16, weight: date.isToday ? .bold : .medium))
                        .foregroundStyle(date.isToday ? .white : .primary)
                        .frame(width: 28, height: 28)
                        .background {
                            if date.isToday {
                                Circle().fill(Color.accentColor)
                            }
                        }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.bottom, 4)
    }

    // MARK: - Time Grid

    private var timeGrid: some View {
        ZStack(alignment: .topLeading) {
            // Hour lines
            VStack(spacing: 0) {
                ForEach(hours, id: \.self) { hour in
                    HStack(alignment: .top, spacing: 0) {
                        Text(String(format: "%02d:00", hour))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .frame(width: 44, alignment: .trailing)
                            .padding(.trailing, 4)

                        Rectangle()
                            .fill(Color(.separator))
                            .frame(height: 0.5)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(height: 60)
                }
            }

            // Events overlay
            HStack(spacing: 1) {
                Spacer()
                    .frame(width: 48)

                ForEach(weekDates, id: \.self) { date in
                    ZStack(alignment: .top) {
                        Color.clear

                        ForEach(eventsFor(date: date), id: \.id) { event in
                            if !event.isAllDay {
                                weekEventBlock(event: event)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func weekEventBlock(event: CalendarEvent) -> some View {
        let startHour = Calendar.current.component(.hour, from: event.startDate)
        let startMinute = Calendar.current.component(.minute, from: event.startDate)
        let topOffset = CGFloat(startHour - hours.first!) * 60 + CGFloat(startMinute)
        let height = max(CGFloat(event.durationMinutes), 20)

        return VStack(alignment: .leading, spacing: 1) {
            Text(event.title)
                .font(.system(size: 10, weight: .medium))
                .lineLimit(2)
            Text(event.startDate.timeString)
                .font(.system(size: 8))
                .foregroundStyle(.secondary)
        }
        .padding(3)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: height)
        .background(event.category?.color.opacity(0.2) ?? Color.blue.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(event.category?.color ?? .blue, lineWidth: 1)
                .opacity(0.5)
        )
        .offset(y: topOffset)
    }

    // MARK: - Helpers

    private var weekDates: [Date] {
        (0..<7).compactMap {
            Calendar.current.date(byAdding: .day, value: $0, to: currentWeekStart)
        }
    }

    private func eventsFor(date: Date) -> [CalendarEvent] {
        allEvents.filter { event in
            Calendar.current.isDate(event.startDate, inSameDayAs: date) ||
            (event.startDate < date.endOfDay && event.endDate > date.startOfDay)
        }
    }

    private func advanceWeek(by value: Int) {
        if let newWeek = Calendar.current.date(byAdding: .weekOfYear, value: value, to: currentWeekStart) {
            currentWeekStart = newWeek
        }
    }
}
