import SwiftUI

enum AppTab: String, CaseIterable {
    case week = "Uge"
    case month = "Måned"
    case agenda = "Agenda"
    case todo = "To-Do"
    case settings = "Indstillinger"

    var icon: String {
        switch self {
        case .month: return "calendar"
        case .week: return "calendar.day.timeline.left"
        case .agenda: return "list.bullet.below.rectangle"
        case .todo: return "checklist"
        case .settings: return "gearshape"
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .week
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        #if os(macOS)
        NavigationSplitView {
            sidebar
        } detail: {
            detailView
        }
        #else
        if horizontalSizeClass == .regular {
            NavigationSplitView {
                sidebar
            } detail: {
                detailView
            }
        } else {
            TabView(selection: $selectedTab) {
                // Week tab — no navigation bar, uses full screen
                WeekView()
                    .tabItem { Label("Uge", systemImage: "calendar.day.timeline.left") }
                    .tag(AppTab.week)

                NavigationStack {
                    MonthView()
                        .navigationTitle("Måned")
                }
                .tabItem { Label("Måned", systemImage: "calendar") }
                .tag(AppTab.month)

                NavigationStack {
                    AgendaView()
                        .navigationTitle("Agenda")
                }
                .tabItem { Label("Agenda", systemImage: "list.bullet.below.rectangle") }
                .tag(AppTab.agenda)

                NavigationStack {
                    TodoListView()
                        .navigationTitle("To-Do")
                }
                .tabItem { Label("To-Do", systemImage: "checklist") }
                .tag(AppTab.todo)

                NavigationStack {
                    SettingsView()
                        .navigationTitle("Indstillinger")
                }
                .tabItem { Label("Indstillinger", systemImage: "gearshape") }
                .tag(AppTab.settings)
            }
        }
        #endif
    }

    private var sidebar: some View {
        List {
            ForEach([AppTab.week, .month, .agenda, .todo], id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Label(tab.rawValue, systemImage: tab.icon)
                }
                .listRowBackground(selectedTab == tab ? Color.accentColor.opacity(0.15) : Color.clear)
            }

            Section("Indstillinger") {
                Button {
                    selectedTab = .settings
                } label: {
                    Label("Indstillinger", systemImage: "gearshape")
                }
                .listRowBackground(selectedTab == .settings ? Color.accentColor.opacity(0.15) : Color.clear)
            }
        }
        .navigationTitle("HejmadiWeek")
    }

    private var detailView: some View {
        NavigationStack {
            viewForTab(selectedTab)
                .navigationTitle(selectedTab.rawValue)
        }
    }

    @ViewBuilder
    private func viewForTab(_ tab: AppTab) -> some View {
        switch tab {
        case .month:
            MonthView()
        case .week:
            WeekView()
        case .agenda:
            AgendaView()
        case .todo:
            TodoListView()
        case .settings:
            SettingsView()
        }
    }
}
