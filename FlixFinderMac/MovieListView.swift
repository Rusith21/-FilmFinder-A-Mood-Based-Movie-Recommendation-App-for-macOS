import SwiftUI

struct MovieListView: View {
    let selectedMood: String
    @State private var movies: [Movie] = []
    @EnvironmentObject var watchlistManager: WatchlistManager
    @State private var selectedMovie: Movie? = nil
    @State private var featuredMovie: Movie?

    let moodGenreMap: [String: Int] = [
        "Happy": 35,
        "Sad": 18,
        "Excited": 28,
        "Romantic": 10749
    ]
    
    var body: some View {
        ZStack {
            // Netflix black background
            Color.black
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Hero section with featured movie
                    if let featured = featuredMovie {
                        NetflixHeroSection(
                            movie: featured,
                            selectedMood: selectedMood,
                            onPlayTap: { selectedMovie = featured },
                            onWatchlistTap: {
                                toggleWatchlist(for: featured)
                            },
                            isInWatchlist: isInWatchlist(featured)
                        )
                        .frame(height: 500)
                    }
                    
                    // Content sections
                    VStack(alignment: .leading, spacing: 32) {
                        // Main mood section
                        NetflixMovieSection(
                            title: "Perfect for your \(selectedMood.lowercased()) mood",
                            movies: movies,
                            onMovieTap: { movie in selectedMovie = movie },
                            onWatchlistToggle: toggleWatchlist,
                            isInWatchlist: isInWatchlist
                        )
                        
                        // My List section (if user has watchlist items)
                        if !watchlistManager.watchlist.isEmpty {
                            NetflixMovieSection(
                                title: "My List",
                                movies: Array(watchlistManager.watchlist.prefix(10)),
                                onMovieTap: { movie in selectedMovie = movie },
                                onWatchlistToggle: { movie in
                                    watchlistManager.remove(movie: movie)
                                },
                                isInWatchlist: { _ in true }
                            )
                        }
                        
                        // Additional sections
                        if movies.count > 8 {
                            NetflixMovieSection(
                                title: "Trending Now",
                                movies: Array(movies.shuffled().prefix(8)),
                                onMovieTap: { movie in selectedMovie = movie },
                                onWatchlistToggle: toggleWatchlist,
                                isInWatchlist: isInWatchlist
                            )
                            
                            NetflixMovieSection(
                                title: "",
                                movies: Array(movies.suffix(8)),
                                onMovieTap: { movie in selectedMovie = movie },
                                onWatchlistToggle: toggleWatchlist,
                                isInWatchlist: isInWatchlist
                            )
                        }
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 60)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            // Loading state
            if movies.isEmpty {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.red)
                    
                    Text("Loading your movies...")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onChange(of: selectedMood, initial: true) { _, _ in
            fetchMovies()
        }
        .sheet(item: $selectedMovie) { movie in
            NetflixMovieDetailView(movie: movie) {
                watchlistManager.add(movie: movie)
            }
        }
    }

    private func fetchMovies() {
        if let genreID = moodGenreMap[selectedMood] {
            MovieService.shared.fetchMovies(for: genreID) { fetchedMovies in
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.movies = fetchedMovies
                    self.featuredMovie = fetchedMovies.first
                }
            }
        }
    }

    private func isInWatchlist(_ movie: Movie) -> Bool {
        return watchlistManager.watchlist.contains(where: { $0.id == movie.id })
    }
    
    private func toggleWatchlist(for movie: Movie) {
        if isInWatchlist(movie) {
            watchlistManager.remove(movie: movie)
        } else {
            watchlistManager.add(movie: movie)
        }
    }
}

// MARK: - Netflix Hero Section
struct NetflixHeroSection: View {
    let movie: Movie
    let selectedMood: String
    let onPlayTap: () -> Void
    let onWatchlistTap: () -> Void
    let isInWatchlist: Bool
    
    var body: some View {
        ZStack {
            // Background image
            if let url = movie.posterURL {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
            }
            
            // Gradient overlay
            LinearGradient(
                colors: [
                    Color.clear,
                    Color.clear,
                    Color.black.opacity(0.3),
                    Color.black.opacity(0.8),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Content
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                
                VStack(alignment: .leading, spacing: 16) {
                    // Netflix badge
                    HStack(alignment: .center, spacing: 8) {
                        Text("N")
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.red)
                            .cornerRadius(2)
                        
                        Text("FILM")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                            .tracking(2)
                        
                        Spacer()
                    }
                    
                    // Movie title
                    Text(movie.title)
                        .font(.system(size: 42, weight: .black))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .shadow(color: .black.opacity(0.8), radius: 4, x: 0, y: 2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Movie description
                    Text(movie.overview)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                        .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Action buttons
                    HStack(alignment: .center, spacing: 12) {
                        Button(action: onPlayTap) {
                            HStack(spacing: 8) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 16, weight: .bold))
                                Text("Play")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundColor(.black)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .cornerRadius(4)
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: onWatchlistTap) {
                            HStack(spacing: 8) {
                                Image(systemName: isInWatchlist ? "checkmark" : "plus")
                                    .font(.system(size: 16, weight: .bold))
                                Text("My List")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.25))
                            .cornerRadius(4)
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

// MARK: - Netflix Movie Section
struct NetflixMovieSection: View {
    let title: String
    let movies: [Movie]
    let onMovieTap: (Movie) -> Void
    let onWatchlistToggle: (Movie) -> Void
    let isInWatchlist: (Movie) -> Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: 8) {
                    ForEach(movies) { movie in
                        NetflixMovieCardView(
                            movie: movie,
                            onMovieTap: { onMovieTap(movie) },
                            onWatchlistToggle: { onWatchlistToggle(movie) },
                            isInWatchlist: isInWatchlist(movie)
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Netflix Movie Card
struct NetflixMovieCardView: View {
    let movie: Movie
    let onMovieTap: () -> Void
    let onWatchlistToggle: () -> Void
    let isInWatchlist: Bool
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onMovieTap) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    if let url = movie.posterURL {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(2/3, contentMode: .fill)
                                .frame(width: 160, height: 240)
                                .clipped()
                                .cornerRadius(6)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 160, height: 240)
                                .cornerRadius(6)
                                .overlay(
                                    ProgressView()
                                        .tint(.red)
                                )
                        }
                    }
                    
                    if isInWatchlist {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.red)
                            .background(Color.black.opacity(0.8))
                            .clipShape(Circle())
                            .padding(6)
                    }
                }
                
                if isHovered {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(movie.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(alignment: .center, spacing: 16) {
                            Button(action: onMovieTap) {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: onWatchlistToggle) {
                                Image(systemName: isInWatchlist ? "checkmark.circle.fill" : "plus.circle")
                                    .font(.system(size: 28))
                                    .foregroundColor(isInWatchlist ? .red : .white)
                            }
                            .buttonStyle(.plain)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.black.opacity(0.95))
                    )
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .frame(width: 160, alignment: .leading)
        }
        .buttonStyle(.plain)
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Netflix Movie Detail View
struct NetflixMovieDetailView: View {
    let movie: Movie
    let onAddToWatchlist: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 24)
                    .padding(.top, 20)
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        HStack(alignment: .top, spacing: 24) {
                            // Movie poster
                            if let url = movie.posterURL {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(2/3, contentMode: .fit)
                                        .frame(width: 200)
                                        .cornerRadius(8)
                                } placeholder: {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 200, height: 300)
                                        .cornerRadius(8)
                                }
                            }
                            
                            // Movie details
                            VStack(alignment: .leading, spacing: 20) {
                                Text(movie.title)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text(movie.overview)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.8))
                                    .lineSpacing(4)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                // Action buttons
                                HStack(alignment: .center, spacing: 16) {
                                    Button(action: {}) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "play.fill")
                                                .font(.system(size: 16))
                                            Text("Play")
                                                .font(.system(size: 16, weight: .semibold))
                                        }
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 12)
                                        .background(Color.white)
                                        .cornerRadius(4)
                                    }
                                    
                                    Button(action: onAddToWatchlist) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "plus")
                                                .font(.system(size: 16))
                                            Text("My List")
                                                .font(.system(size: 16, weight: .semibold))
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 12)
                                        .background(Color.white.opacity(0.25))
                                        .cornerRadius(4)
                                    }
                                    
                                    Spacer()
                                }
                                .buttonStyle(.plain)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}
