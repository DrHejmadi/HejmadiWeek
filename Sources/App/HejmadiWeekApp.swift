import SwiftUI
import SwiftData

@main
struct HejmadiWeekApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([
                CalendarCategory.self,
                CalendarEvent.self,
                TodoItem.self
            ])
            let config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .automatic
            )
            modelContainer = try ModelContainer(for: schema, configurations: [config])

            // Seed default categories on first launch
            let context = modelContainer.mainContext
            let descriptor = FetchDescriptor<CalendarCategory>()
            let count = (try? context.fetchCount(descriptor)) ?? 0
            if count == 0 {
                CalendarCategory.seedDefaults(in: context)
            }
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)

        #if os(macOS)
        Settings {
            SettingsView()
                .modelContainer(modelContainer)
        }

        MenuBarExtra("HejmadiWeek", systemImage: "calendar") {
            MenuBarView()
                .modelContainer(modelContainer)
        }
        #endif
    }
}
