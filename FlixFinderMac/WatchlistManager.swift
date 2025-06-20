import Foundation

class WatchlistManager: ObservableObject {
    @Published var watchlist: [Movie] {
        didSet {
            saveWatchlist()
        }
    }

    init() {
        if let data = UserDefaults.standard.data(forKey: "Watchlist"),
           let decoded = try? JSONDecoder().decode([Movie].self, from: data) {
            self.watchlist = decoded
        } else {
            self.watchlist = []
        }
    }

    func add(movie: Movie) {
        if !watchlist.contains(where: { $0.id == movie.id }) {
            watchlist.append(movie)
        }
    }

    func remove(movie: Movie) {
        watchlist.removeAll { $0.id == movie.id }
    }

    private func saveWatchlist() {
        if let encoded = try? JSONEncoder().encode(watchlist) {
            UserDefaults.standard.set(encoded, forKey: "Watchlist")
        }
    }
}

// MARK: - Sharing Extension
extension WatchlistManager {
    // Function to share entire watchlist
    func getWatchlistSummary() -> String {
        guard !watchlist.isEmpty else {
            return "My movie watchlist is currently empty. Time to add some great movies! 🎬"
        }
        
        var summary = "🎬 My Movie Watchlist (\(watchlist.count) \(watchlist.count == 1 ? "movie" : "movies")):\n\n"
        
        for (index, movie) in watchlist.enumerated() {
            summary += "\(index + 1). \(movie.title)"
            if let voteAverage = movie.voteAverage, voteAverage > 0 {
                summary += " ⭐ \(String(format: "%.1f", voteAverage))"
            }
            summary += "\n"
        }
        
        summary += "\nShared from my movie app! 🍿"
        return summary
    }
    
    // Function to get top rated movies from watchlist for sharing
    func getTopRatedMoviesForSharing(limit: Int = 5) -> String {
        let topMovies = watchlist
            .compactMap { movie -> (Movie, Double)? in
                guard let voteAverage = movie.voteAverage, voteAverage > 0 else { return nil }
                return (movie, voteAverage)
            }
            .sorted { $0.1 > $1.1 }
            .prefix(limit)
        
        guard !topMovies.isEmpty else {
            return "Check out my movie watchlist! I have \(watchlist.count) movies ready to watch. 🎬🍿"
        }
        
        var shareText = "🏆 Top movies from my watchlist:\n\n"
        
        for (index, movieTuple) in topMovies.enumerated() {
            let (movie, rating) = movieTuple
            shareText += "\(index + 1). \(movie.title) ⭐ \(String(format: "%.1f", rating))\n"
        }
        
        if watchlist.count > limit {
            shareText += "\n...and \(watchlist.count - limit) more movies! 🎬"
        }
        
        shareText += "\n\nShared from my movie app! 🍿"
        return shareText
    }
    
    // Function to create shareable content for individual movie
    func createShareableContent(for movie: Movie) -> String {
        var shareText = "🎬 \(movie.title)\n\n"
        
        if !movie.overview.isEmpty {
            shareText += "\(movie.overview)\n\n"
        }
        
        // Handle release date - convert string to date if needed
        if let releaseDateString = movie.releaseDate, !releaseDateString.isEmpty {
            // Try to parse the date string and format it nicely
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "yyyy-MM-dd" // Common API format
            
            if let date = inputFormatter.date(from: releaseDateString) {
                let outputFormatter = DateFormatter()
                outputFormatter.dateStyle = .medium
                shareText += "Release Date: \(outputFormatter.string(from: date))\n"
            } else {
                // If parsing fails, just use the original string
                shareText += "Release Date: \(releaseDateString)\n"
            }
        }
        
        if let voteAverage = movie.voteAverage, voteAverage > 0 {
            shareText += "Rating: ⭐ \(String(format: "%.1f", voteAverage))/10\n"
        }
        
        shareText += "\nAdded to my movie watchlist! 🍿"
        
        return shareText
    }
}
