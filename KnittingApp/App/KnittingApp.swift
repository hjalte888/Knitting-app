import SwiftUI
import SwiftData

@main
struct KnittingApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: Project.self, Pattern.self, YarnStash.self, Needle.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
        }
    }
}
