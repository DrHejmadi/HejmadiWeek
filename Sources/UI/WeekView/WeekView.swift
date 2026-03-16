import SwiftUI
import SwiftData

struct WeekView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CalendarEvent.startDate) private var allEvents: [CalendarEvent]

    @State private var currentWeekStart = Date().startOfWeek
    @State private var showEventEditor = false
    @State private var selectedDate = Date()
    @State private var editingEvent: CalendarEvent?
    var ekManager: EventKitManager = .shared

    private let hours = Array(0...23)
    private let hourHeight: CGFloat = 60

    var body: some View {
        VStack(spacing: 0) {
            weekHeader
            weekDayStrip
            allDaySection

            ScrollViewReader { proxy in
                ScrollView {
                    timeGrid
                        .id("timeGrid")
                }
                .onAppear {
                    // Scroll to 7 AM on appear
                    proxy.scrollTo(7, anchor: .top)
                }
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
        .sheet(item: $editingEvent) { event in
            EventEditorView(initialDate: event.startDate, existingEvent: event)
        }
        .onAppear {
            Task {
                if !ekManager.isAuthorized {
                    await ekManager.requestAccess()
                }
                ekManager.fetchEventsForMonth(containing: currentWeekStart)
            }
        }
        .onChange(of: currentWeekStart) { _, newValue in
            ekManager.fetchEventsForMonth(containing: newValue)
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
                .onTapGesture {
                    selectedDate = date
                    showEventEditor = true
                }
            }
        }
        .padding(.bottom, 4)
    }

    // MARK: - All Day Section

    private var allDaySection: some View {
        let allDayEvents = weekDates.flatMap { date in
            displayEventsFor(date: date).filter { $0.isAllDay }
        }
        // Deduplicate
        var seen = Set<String>()
        let uniqueEvents = allDayEvents.filter { seen.insert($0.id).inserted }

        return Group {
            if !uniqueEvents.isEmpty {
                VStack(spacing: 2) {
                    HStack(spacing: 0) {
                        Text("Hel dag")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .frame(width: 44, alignment: .trailing)
                            .padding(.trailing, 4)

                        ForEach(weekDates, id: \.self) { date in
                            let dayAllDay = displayEventsFor(date: date).filter { $0.isAllDay }
                            VStack(spacing: 1) {
                                ForEach(dayAllDay) { event in
                                    Text(event.title)
                                        .font(.system(size: 9, weight: .medium))
                                        .lineLimit(1)
                                        .padding(.horizontal, 2)
                                        .padding(.vertical, 1)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(event.color.opacity(0.2))
                                        .clipShape(RoundedRectangle(cornerRadius: 2))
                                        .onTapGesture {
                                            if let source = event.sourceEvent {
                                                editingEvent = source
                                            }
                                        }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 4)

                    Divider()
                }
            }
        }
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
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 0.5)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(height: hourHeight)
                    .id(hour)
                }
            }

            // Events overlay
            HStack(spacing: 1) {
                Spacer()
                    .frame(width: 48)

                ForEach(weekDates, id: \.self) { date in
                    ZStack(alignment: .top) {
                        Color.clear

                        ForEach(displayEventsFor(date: date).filter({ !$0.isAllDay })) { event in
                            weekEventBlock(event: event)
                                .onTapGesture {
                                    if let source = event.sourceEvent {
                                        editingEvent = source
                                    }
                                }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func weekEventBlock(event: DisplayEvent) -> some View {
        let startHour = Calendar.current.component(.hour, from: event.startDate)
        let startMinute = Calendar.current.component(.minute, from: event.startDate)
        let topOffset = CGFloat(startHour) * hourHeight + CGFloat(startMinute)
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
        .background(event.color.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(event.color, lineWidth: 1)
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

    private func displayEventsFor(date: Date) -> [DisplayEvent] {
        let internal_ = eventsFor(date: date).map { DisplayEvent(event: $0) }
        let external = ekManager.eventsFor(date: date)
        return (internal_ + external).sorted { $0.startDate < $1.startDate }
    }

    private func advanceWeek(by value: Int) {
        if let newWeek = Calendar.current.date(byAdding: .weekOfYear, value: value, to: currentWeekStart) {
            currentWeekStart = newWeek
        }
    }
}
