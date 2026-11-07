import SwiftUI
import SwiftData

@main
struct IdeaVaultApp: App {
    var body: some Scene {
        WindowGroup {
            IdeaListView()
                .tint(.orange)
        }
        .modelContainer(for: Idea.self)
    }
}
