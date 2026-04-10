import SwiftUI
import SwiftData

struct WeekView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CalendarEvent.startDate) private var allEvents: [CalendarEvent]

    @State private var currentWeekStart = Date().startOfWeek
    @State private var showEventEditor = false
    @State private var selectedDate = Date()
    @State private var editingEvent: CalendarEvent?
    @State private var peekDate: Date?
    @State private var showPeek = false
    var ekManager: EventKitManager = .shared

    @State private var showFullDay = false
    private let coreHoursRange = 7...21
    private let hourHeight: CGFloat = 60

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                weekHeader
                    .padding(.top, 4)
                weekDayStrip
                allDaySection

                ScrollViewReader { proxy in
                    ScrollView {
                        timeGrid
                            .id("timeGrid")
                    }
                    .onAppear {
                        if showFullDay {
                            proxy.scrollTo(7, anchor: .top)
                        }
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

            // Day peek overlay
            if showPeek, let peekDate {
                DayPeekView(
                    date: peekDate,
                    events: eventsFor(date: peekDate),
                    displayEvents: displayEventsFor(date: peekDate),
                    onClose: { withAnimation(.spring(response: 0.3)) { showPeek = false } },
                    onAddEvent: {
                        selectedDate = peekDate
                        showPeek = false
                        showEventEditor = true
                    },
                    onEditEvent: { event in
                        showPeek = false
                        editingEvent = event
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
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
                    .font(.title3.weight(.semibold))
            }

            Spacer()

            VStack(spacing: 0) {
                Text(monthLabel)
                    .font(.title3.weight(.bold))
                Text("Uge \(currentWeekStart.weekNumber)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

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
                    .font(.title3.weight(.semibold))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }

    /// Shows the month name(s) covered by this week
    private var monthLabel: String {
        let dates = weekDates
        guard let first = dates.first, let last = dates.last else { return "" }
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "da_DK")
        fmt.dateFormat = "MMMM"
        let firstMonth = fmt.string(from: first).capitalized
        let lastMonth = fmt.string(from: last).capitalized
        if firstMonth == lastMonth {
            return firstMonth
        }
        return "\(firstMonth) / \(lastMonth)"
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
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedDate = date
                    showEventEditor = true
                }
                .onLongPressGesture {
                    withAnimation(.spring(response: 0.3)) {
                        if peekDate?.isSameDay(as: date) == true && showPeek {
                            showPeek = false
                        } else {
                            peekDate = date
                            showPeek = true
                        }
                    }
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

    private var visibleHours: [Int] {
        if showFullDay { return Array(0...23) }
        return Array(coreHoursRange)
    }

    private var timeGrid: some View {
        VStack(spacing: 0) {
            // Collapsed early hours indicator
            if !showFullDay {
                Button {
                    withAnimation(.spring(response: 0.3)) { showFullDay = true }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 8))
                        Text("00–06")
                            .font(.system(size: 9))
                    }
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.04))
                }
                .buttonStyle(.plain)
            }

            ZStack(alignment: .topLeading) {
                VStack(spacing: 0) {
                    ForEach(visibleHours, id: \.self) { hour in
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

            // Collapsed late hours indicator
            if !showFullDay {
                Button {
                    withAnimation(.spring(response: 0.3)) { showFullDay = true }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 8))
                        Text("22–23")
                            .font(.system(size: 9))
                    }
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.04))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func weekEventBlock(event: DisplayEvent) -> some View {
        let startHour = Calendar.current.component(.hour, from: event.startDate)
        let startMinute = Calendar.current.component(.minute, from: event.startDate)
        let firstVisibleHour = showFullDay ? 0 : coreHoursRange.lowerBound
        let topOffset = CGFloat(startHour - firstVisibleHour) * hourHeight + CGFloat(startMinute)
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
