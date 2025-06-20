import SwiftUI

struct ContentView: View {
    @State private var selectedMood: String = "Happy"
    @StateObject private var watchlistManager = WatchlistManager()

    var body: some View {
        TabView {
            NavigationSplitView {
                SidebarView(selectedMood: $selectedMood)
            } detail: {
                MovieListView(selectedMood: selectedMood)
                    .environmentObject(watchlistManager)
            }
            .tabItem {
                Label("Home", systemImage: "film")
            }

            WatchlistView(watchlistManager: watchlistManager)
                .tabItem {
                    Label("Watchlist", systemImage: "star.fill")
                }

            SearchView(watchlistManager: watchlistManager)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
        }
    }
}

