import SwiftUI

@main
struct FlixFinderMacApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandMenu("FlixFinder") {
                Button("About This App") {
                    print("FlixFinder for macOS - Mood-based Movie Recommender")
                }
            }
        }
    }
}

