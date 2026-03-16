import SwiftUI
import SwiftData

struct MonthView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentMonth = Date()
    @State private var selectedDate: Date? = Date()
    @State private var showDayPeek = false
    @State private var showEventEditor = false
    @State private var editingEvent: CalendarEvent?
    @State private var dragOffset: CGFloat = 0
    var ekManager: EventKitManager = .shared

    @Query(sort: \CalendarEvent.startDate) private var allEvents: [CalendarEvent]
    @Query(sort: \CalendarCategory.sortOrder) private var categories: [CalendarCategory]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 1), count: 7)
    private let weekdays = ["Man", "Tir", "Ons", "Tor", "Fre", "Lør", "Søn"]

    var body: some View {
        VStack(spacing: 0) {
            monthHeader
            weekdayHeader
            monthGrid
            if showDayPeek, let selected = selectedDate {
                DayPeekView(
                    date: selected,
                    events: eventsFor(date: selected),
                    displayEvents: displayEventsFor(date: selected),
                    onClose: { withAnimation(.spring(response: 0.3)) { showDayPeek = false } },
                    onAddEvent: { showEventEditor = true },
                    onEditEvent: { event in editingEvent = event }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    if value.translation.height < -50 {
                        withAnimation(.spring(response: 0.4)) { advanceMonth(by: 1) }
                    } else if value.translation.height > 50 {
                        withAnimation(.spring(response: 0.4)) { advanceMonth(by: -1) }
                    }
                }
        )
        .sheet(isPresented: $showEventEditor) {
            EventEditorView(initialDate: selectedDate ?? Date())
        }
        .sheet(item: $editingEvent) { event in
            EventEditorView(initialDate: event.startDate, existingEvent: event)
        }
        .onAppear {
            Task {
                if !ekManager.isAuthorized {
                    await ekManager.requestAccess()
                }
                ekManager.fetchEventsForMonth(containing: currentMonth)
            }
        }
        .onChange(of: currentMonth) { _, newValue in
            ekManager.fetchEventsForMonth(containing: newValue)
        }
    }

    // MARK: - Month Header

    private var monthHeader: some View {
        HStack {
            Button { withAnimation(.spring(response: 0.4)) { advanceMonth(by: -1) } } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
            }

            Spacer()

            Text(currentMonth.monthName)
                .font(.title2.weight(.bold))

            Spacer()

            HStack(spacing: 16) {
                Button {
                    withAnimation(.spring(response: 0.4)) { currentMonth = Date() }
                    selectedDate = Date()
                } label: {
                    Text("I dag")
                        .font(.subheadline.weight(.medium))
                }

                Button { withAnimation(.spring(response: 0.4)) { advanceMonth(by: 1) } } label: {
                    Image(systemName: "chevron.right")
                        .font(.title3.weight(.semibold))
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }

    // MARK: - Weekday Header

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            // Week number column
            Text("Uge")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .frame(width: 30)

            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(day == "Lør" || day == "Søn" ? .secondary : .primary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 4)
    }

    // MARK: - Month Grid

    private var monthGrid: some View {
        let gridDates = currentMonth.monthGridDates()
        let weeks = stride(from: 0, to: gridDates.count, by: 7).map {
            Array(gridDates[$0..<min($0 + 7, gridDates.count)])
        }

        return VStack(spacing: 1) {
            ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
                HStack(spacing: 0) {
                    // Week number
                    Text("\(week.first?.weekNumber ?? 0)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .frame(width: 30)

                    ForEach(week, id: \.self) { date in
                        MonthDayCell(
                            date: date,
                            isCurrentMonth: date.isSameMonth(as: currentMonth),
                            isSelected: selectedDate?.isSameDay(as: date) == true,
                            isToday: date.isToday,
                            events: eventsFor(date: date),
                            categories: categories,
                            displayEvents: displayEventsFor(date: date)
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                if selectedDate?.isSameDay(as: date) == true {
                                    showDayPeek.toggle()
                                } else {
                                    selectedDate = date
                                    showDayPeek = true
                                }
                            }
                        }
                        .onLongPressGesture {
                            selectedDate = date
                            showEventEditor = true
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Helpers

    private func eventsFor(date: Date) -> [CalendarEvent] {
        allEvents.filter { event in
            if event.isAllDay {
                return Calendar.current.isDate(event.startDate, inSameDayAs: date) ||
                       (event.startDate <= date.endOfDay && event.endDate >= date.startOfDay)
            }
            return Calendar.current.isDate(event.startDate, inSameDayAs: date) ||
                   (event.startDate < date.endOfDay && event.endDate > date.startOfDay)
        }
    }

    private func displayEventsFor(date: Date) -> [DisplayEvent] {
        let internal_ = eventsFor(date: date).map { DisplayEvent(event: $0) }
        let external = ekManager.eventsFor(date: date)
        return (internal_ + external).sorted { $0.startDate < $1.startDate }
    }

    private func advanceMonth(by value: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
        }
    }
}
