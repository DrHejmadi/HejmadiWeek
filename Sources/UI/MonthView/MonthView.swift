import SwiftUI
import SwiftData
import EventKit

struct MonthView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentMonth = Date()
    @State private var selectedDate: Date? = Date()
    @State private var showEventEditor = false
    @State private var editingEvent: CalendarEvent?
    @State private var zoomedDate: Date?
    @State private var showCalendarPicker = false
    @State private var showFilterPopover = false
    @State private var ekManager = EventKitManager.shared
    @State private var zoomHeight: CGFloat = 400
    var onSwitchToWeek: ((Date) -> Void)?

    @Query(sort: \CalendarEvent.startDate) private var allEvents: [CalendarEvent]
    @Query(sort: \CalendarCategory.sortOrder) private var categories: [CalendarCategory]
    @AppStorage("dayCellMode") private var dayCellMode = "titles"
    @AppStorage("showHeatmap") private var showHeatmap = true

    private let weekdays = ["Man", "Tir", "Ons", "Tor", "Fre", "Lør", "Søn"]

    // Cached event lookup — computed once per render, not per cell
    private var eventsByDate: [String: [DisplayEvent]] {
        var dict: [String: [DisplayEvent]] = [:]
        let gridDates = currentMonth.monthGridDates()
        for date in gridDates {
            let key = date.dateCacheKey
            let internal_ = allEvents.filter { event in
                if event.isAllDay {
                    return Calendar.current.isDate(event.startDate, inSameDayAs: date) ||
                           (event.startDate <= date.endOfDay && event.endDate >= date.startOfDay)
                }
                return Calendar.current.isDate(event.startDate, inSameDayAs: date) ||
                       (event.startDate < date.endOfDay && event.endDate > date.startOfDay)
            }.map { DisplayEvent(event: $0) }
            let external = ekManager.eventsFor(date: date)
            dict[key] = (internal_ + external).sorted { $0.startDate < $1.startDate }
        }
        return dict
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack(spacing: 0) {
                    monthHeader
                        .padding(.top, 4)
                    weekdayHeader
                    monthGrid
                        .frame(maxHeight: .infinity)
                    Spacer(minLength: 0)
                }
                .gesture(
                    DragGesture(minimumDistance: 50)
                        .onEnded { value in
                            // Horizontal swipe = change month
                            if abs(value.translation.width) > abs(value.translation.height) {
                                if value.translation.width < -50 {
                                    withAnimation(.spring(response: 0.4)) { advanceMonth(by: 1) }
                                } else if value.translation.width > 50 {
                                    withAnimation(.spring(response: 0.4)) { advanceMonth(by: -1) }
                                }
                            } else {
                                // Vertical swipe = also change month
                                if value.translation.height < -50 {
                                    withAnimation(.spring(response: 0.4)) { advanceMonth(by: 1) }
                                } else if value.translation.height > 50 {
                                    withAnimation(.spring(response: 0.4)) { advanceMonth(by: -1) }
                                }
                            }
                        }
                )

                // Day zoom overlay (long-press / hover)
                if let zDate = zoomedDate {
                    dayZoomOverlay(for: zDate, screenHeight: geo.size.height)
                }
            }
        }
        .gesture(
            MagnificationGesture()
                .onEnded { scale in
                    if scale > 1.5 {
                        onSwitchToWeek?(selectedDate ?? Date())
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

    // MARK: - Month Header (compact)

    private var monthHeaderText: String {
        let cal = Calendar.current
        let isCurrentYear = cal.component(.year, from: currentMonth) == cal.component(.year, from: Date())
        return isCurrentYear ? currentMonth.monthName : currentMonth.monthNameFull
    }

    private var monthHeader: some View {
        HStack(spacing: 8) {
            Button("Forrige", systemImage: "chevron.left") {
                withAnimation(.spring(response: 0.4)) { advanceMonth(by: -1) }
            }
            .labelStyle(.iconOnly)
            .font(.body.weight(.semibold))

            Text(monthHeaderText)
                .font(.headline.weight(.bold))

            Button("Næste", systemImage: "chevron.right") {
                withAnimation(.spring(response: 0.4)) { advanceMonth(by: 1) }
            }
            .labelStyle(.iconOnly)
            .font(.body.weight(.semibold))

            Spacer()

            Button {
                withAnimation(.spring(response: 0.4)) { currentMonth = Date() }
                selectedDate = Date()
            } label: {
                Text("I dag")
                    .font(.caption2.weight(.medium))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.accentColor.opacity(0.12))
                    .clipShape(Capsule())
            }

            // Filter popover button — keeps dots out of the header
            Button {
                showFilterPopover.toggle()
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .popover(isPresented: $showFilterPopover) {
                calendarFilterContent()
                    .presentationCompactAdaptation(.popover)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    private func calendarFilterContent() -> some View {
        CalendarFilterPopover(
            categories: Array(categories.prefix(8)),
            ekManager: ekManager
        )
    }

    // MARK: - Weekday Header

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            Text("Uge")
                .font(.system(size: 8))
                .foregroundStyle(.tertiary)
                .frame(width: 22)

            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(day == "Lør" || day == "Søn" ? .secondary : .primary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 2)
        .padding(.bottom, 2)
    }

    // MARK: - Month Grid

    private var monthGrid: some View {
        let gridDates = currentMonth.monthGridDates()
        let weeks = stride(from: 0, to: gridDates.count, by: 7).map {
            Array(gridDates[$0..<min($0 + 7, gridDates.count)])
        }
        // Adaptive: more events visible when fewer weeks
        let maxEvents = weeks.count <= 5 ? 4 : 3

        return VStack(spacing: 0) {
            ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
                let weekContainsToday = week.contains { $0.isToday }
                HStack(spacing: 0) {
                    Text("\(week.first?.weekNumber ?? 0)")
                        .font(.system(size: 9).monospacedDigit())
                        .foregroundStyle(.tertiary)
                        .frame(width: 22)

                    ForEach(week, id: \.self) { date in
                        let cachedEvents = eventsByDate[date.dateCacheKey] ?? []
                        let isCurrentMonth = date.isSameMonth(as: currentMonth)
                        MonthDayCell(
                            date: date,
                            isCurrentMonth: isCurrentMonth,
                            isSelected: selectedDate?.isSameDay(as: date) == true,
                            isToday: date.isToday,
                            events: allEvents.filter { Calendar.current.isDate($0.startDate, inSameDayAs: date) },
                            categories: categories,
                            displayEvents: cachedEvents,
                            dayCellMode: dayCellMode,
                            showHeatmap: showHeatmap,
                            showEventsOutsideMonth: true,
                            maxVisibleEvents: maxEvents
                        )
                        .frame(maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture(count: 2) {
                            selectedDate = date
                            showEventEditor = true
                        }
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                selectedDate = date
                            }
                        }
                        .onLongPressGesture {
                            withAnimation(.spring(response: 0.3)) {
                                zoomedDate = date
                            }
                        }
                        .accessibilityLabel(date.formatted(.dateTime.day().month(.wide)))
                        .accessibilityHint(cachedEvents.isEmpty ? "Ingen begivenheder" : "\(cachedEvents.count) begivenheder")
                    }
                }
                .background(
                    weekContainsToday
                        ? Color.pink.opacity(0.06)
                        : Color.clear
                )
                .clipShape(RoundedRectangle(cornerRadius: 3))
            }
        }
        .padding(.horizontal, 2)
    }

    // MARK: - Day Zoom Overlay

    private func dayZoomOverlay(for date: Date, screenHeight: CGFloat) -> some View {
        let dayEvents = eventsByDate[date.dateCacheKey] ?? []

        return ZStack {
            // Dimmed background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.3)) {
                        zoomedDate = nil
                    }
                }
                .accessibilityAddTraits(.isButton)
                .accessibilityLabel("Luk dagsvisning")

            // Zoomed day card
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(date.formatted(.dateTime.weekday(.wide).locale(Locale(identifier: "da_DK"))))
                            .font(.title2.weight(.bold))
                        Text(date.formatted(.dateTime.day().month(.wide).year().locale(Locale(identifier: "da_DK"))))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button("Tilføj begivenhed", systemImage: "plus.circle.fill") {
                        zoomedDate = nil
                        selectedDate = date
                        showEventEditor = true
                    }
                    .labelStyle(.iconOnly)
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)

                    Button("Luk", systemImage: "xmark.circle.fill") {
                        withAnimation(.spring(response: 0.3)) { zoomedDate = nil }
                    }
                    .labelStyle(.iconOnly)
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
                }
                .padding()

                Divider()

                // Events
                if dayEvents.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 40))
                            .foregroundStyle(.tertiary)
                        Text("Ingen begivenheder")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical, 40)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(dayEvents) { event in
                                zoomEventRow(event: event)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        if let source = event.sourceEvent {
                                            zoomedDate = nil
                                            editingEvent = source
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(maxHeight: screenHeight * 0.5)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.2), radius: 20, y: 5)
            .padding(.horizontal, 16)
            .transition(.scale(scale: 0.8).combined(with: .opacity))
            .gesture(
                DragGesture(minimumDistance: 50)
                    .onEnded { value in
                        // Swipe left/right on zoom = navigate days
                        if abs(value.translation.width) > abs(value.translation.height) {
                            withAnimation(.spring(response: 0.3)) {
                                if value.translation.width < -50 {
                                    // Swipe left = next day
                                    if let next = Calendar.current.date(byAdding: .day, value: 1, to: date) {
                                        zoomedDate = next
                                        selectedDate = next
                                    }
                                } else if value.translation.width > 50 {
                                    // Swipe right = previous day
                                    if let prev = Calendar.current.date(byAdding: .day, value: -1, to: date) {
                                        zoomedDate = prev
                                        selectedDate = prev
                                    }
                                }
                            }
                        }
                    }
            )
        }
    }

    private func zoomEventRow(event: DisplayEvent) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 3)
                .fill(event.color)
                .frame(width: 5, height: 44)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Text(event.title)
                        .font(.body.weight(.medium))
                        .lineLimit(1)
                    if event.isExternal {
                        Image(systemName: "apple.logo")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .accessibilityLabel("Apple Kalender")
                    }
                }

                HStack(spacing: 6) {
                    if event.isAllDay {
                        Text("Hele dagen")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("\(event.startDate.timeString) – \(event.endDate.timeString)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if !event.location.isEmpty {
                        HStack(spacing: 2) {
                            Image(systemName: "location.fill")
                                .font(.caption2)
                            Text(event.location)
                                .font(.subheadline)
                                .lineLimit(1)
                        }
                        .foregroundStyle(.secondary)
                    }

                    if event.attendeeCount > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "person.2.fill")
                                .font(.caption2)
                            Text("\(event.attendeeCount)")
                                .font(.subheadline)
                        }
                        .foregroundStyle(.secondary)
                    }
                }

                if let url = event.url {
                    Link(destination: url) {
                        HStack(spacing: 2) {
                            Image(systemName: "link")
                                .font(.caption2)
                            Text(url.host ?? url.absoluteString)
                                .font(.caption)
                                .lineLimit(1)
                        }
                        .foregroundStyle(.blue)
                    }
                }
            }

            Spacer()

            Text(event.calendarName)
                .font(.caption)
                .foregroundStyle(event.color)

            if !event.isExternal {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.primary.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .accessibilityElement(children: .combine)
    }

    // MARK: - Helpers

    private func advanceMonth(by value: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
        }
    }
}

// MARK: - Calendar Filter Popover

struct CalendarFilterPopover: View {
    let categories: [CalendarCategory]
    @Bindable var ekManager: EventKitManager

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Kalendere")
                .font(.subheadline.weight(.semibold))

            ForEach(categories) { cat in
                HStack(spacing: 8) {
                    Circle().fill(cat.color).frame(width: 12, height: 12)
                    Text(cat.name).font(.subheadline)
                    Spacer()
                }
            }

            if ekManager.isAuthorized {
                ForEach(ekManager.ekCalendars, id: \.calendarIdentifier) { cal in
                    calendarRow(cal)
                }
            }
        }
        .padding()
        .frame(minWidth: 200)
    }

    private func calendarRow(_ cal: EKCalendar) -> some View {
        let calId = cal.calendarIdentifier
        let enabled = ekManager.isCalendarEnabled(calId)
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                ekManager.toggleCalendar(calId)
            }
        } label: {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color(cgColor: cal.cgColor))
                    .frame(width: 12, height: 12)
                Text(cal.title).font(.subheadline)
                Spacer()
                if enabled {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundStyle(Color.accentColor)
                }
            }
            .foregroundStyle(.primary)
        }
        .buttonStyle(.plain)
    }
}

// Cache key extension
private extension Date {
    var dateCacheKey: String {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month, .day], from: self)
        return "\(comps.year!)-\(comps.month!)-\(comps.day!)"
    }
}
