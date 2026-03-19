import SwiftUI
import SwiftData

struct MonthView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentMonth = Date()
    @State private var selectedDate: Date? = Date()
    @State private var showEventEditor = false
    @State private var editingEvent: CalendarEvent?
    @State private var zoomedDate: Date?
    @State private var showCalendarPicker = false
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
                        .padding(.top, 8)
                    weekdayHeader
                    monthGrid
                        .frame(maxHeight: .infinity)
                    Spacer(minLength: 0)
                }

                // Day zoom overlay (long-press / hover)
                if let zDate = zoomedDate {
                    dayZoomOverlay(for: zDate, screenHeight: geo.size.height)
                }
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
        .gesture(
            MagnificationGesture()
                .onEnded { scale in
                    if scale > 1.5 {
                        // Pinch out = zoom in = go to week view
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

    // MARK: - Month Header

    private var monthHeader: some View {
        HStack(spacing: 12) {
            Button("Forrige måned", systemImage: "chevron.left") {
                withAnimation(.spring(response: 0.4)) { advanceMonth(by: -1) }
            }
            .labelStyle(.iconOnly)
            .font(.title3.weight(.semibold))

            Text(currentMonth.monthName)
                .font(.title.weight(.bold))

            Button("Næste måned", systemImage: "chevron.right") {
                withAnimation(.spring(response: 0.4)) { advanceMonth(by: 1) }
            }
            .labelStyle(.iconOnly)
            .font(.title3.weight(.semibold))

            Spacer()

            Button {
                withAnimation(.spring(response: 0.4)) { currentMonth = Date() }
                selectedDate = Date()
            } label: {
                Text("I dag")
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.12))
                    .clipShape(Capsule())
            }

            // Calendar filter circles
            calendarFilterButtons
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }

    private var calendarFilterButtons: some View {
        HStack(spacing: 6) {
            // Internal categories
            ForEach(categories.prefix(5)) { cat in
                Circle()
                    .fill(cat.color)
                    .frame(width: 14, height: 14)
                    .overlay(
                        Circle()
                            .stroke(Color.primary.opacity(0.2), lineWidth: 0.5)
                    )
                    .accessibilityLabel("Kategori: \(cat.name)")
            }

            // External Apple calendars (up to 5 total combined)
            let remainingSlots = max(0, 5 - categories.count)
            if ekManager.isAuthorized {
                ForEach(ekManager.ekCalendars.prefix(remainingSlots), id: \.calendarIdentifier) { cal in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            ekManager.toggleCalendar(cal.calendarIdentifier)
                        }
                    } label: {
                        Circle()
                            .fill(Color(cgColor: cal.cgColor))
                            .frame(width: 14, height: 14)
                            .opacity(ekManager.isCalendarEnabled(cal.calendarIdentifier) ? 1.0 : 0.25)
                            .overlay(
                                Circle()
                                    .stroke(Color.primary.opacity(0.2), lineWidth: 0.5)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(cal.title): \(ekManager.isCalendarEnabled(cal.calendarIdentifier) ? "aktiv" : "deaktiveret")")
                }
            }
        }
    }

    // MARK: - Weekday Header

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
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
                    Text("\(week.first?.weekNumber ?? 0)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .frame(width: 30)

                    ForEach(week, id: \.self) { date in
                        let cachedEvents = eventsByDate[date.dateCacheKey] ?? []
                        MonthDayCell(
                            date: date,
                            isCurrentMonth: date.isSameMonth(as: currentMonth),
                            isSelected: selectedDate?.isSameDay(as: date) == true,
                            isToday: date.isToday,
                            events: allEvents.filter { Calendar.current.isDate($0.startDate, inSameDayAs: date) },
                            categories: categories,
                            displayEvents: cachedEvents,
                            dayCellMode: dayCellMode,
                            showHeatmap: showHeatmap
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
            }
        }
        .padding(.horizontal, 4)
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

// Cache key extension
private extension Date {
    var dateCacheKey: String {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month, .day], from: self)
        return "\(comps.year!)-\(comps.month!)-\(comps.day!)"
    }
}
