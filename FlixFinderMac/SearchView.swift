import SwiftUI

struct SearchView: View {
    @ObservedObject var watchlistManager: WatchlistManager
    @State private var query: String = ""
    @State private var releaseYear: String = ""
    @State private var minRating: Double = 0.0
    @State private var results: [Movie] = []
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var selectedMovie: Movie? = nil
    @FocusState private var isSearchFocused: Bool

    // Netflix theme colors
    let netflixColors = (primary: Color.red, secondary: Color(red: 0.9, green: 0.9, blue: 0.9), accent: Color(red: 1.0, green: 0.2, blue: 0.2))
    let netflixBackground = Color(red: 0.08, green: 0.08, blue: 0.08)
    let netflixDark = Color(red: 0.12, green: 0.12, blue: 0.12)
    let netflixGray = Color(red: 0.2, green: 0.2, blue: 0.2)

    var body: some View {
        ZStack {
            // Netflix dark background
            netflixBackground
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Netflix-style header
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SEARCH")
                                .font(.system(size: 14, weight: .bold, design: .default))
                                .foregroundColor(netflixColors.secondary.opacity(0.7))
                                .tracking(2)
                            
                            Text("Movies")
                                .font(.system(size: 36, weight: .bold, design: .default))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        // Netflix logo-inspired search icon
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(netflixColors.primary)
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .scaleEffect(isSearchFocused ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isSearchFocused)
                    }
                    
                    // Netflix-style search section
                    VStack(spacing: 16) {
                        // Main search bar
                        HStack(spacing: 0) {
                            HStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.white.opacity(0.7))
                                    .font(.system(size: 16, weight: .medium))
                                
                                TextField("Search movies...", text: $query)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .onSubmit { search() }
                                    .focused($isSearchFocused)
                                
                                if !query.isEmpty {
                                    Button(action: { query = "" }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white.opacity(0.6))
                                            .font(.system(size: 16))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(netflixDark)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(
                                        isSearchFocused ? netflixColors.primary : Color.white.opacity(0.3),
                                        lineWidth: isSearchFocused ? 2 : 1
                                    )
                            )
                            .animation(.easeInOut(duration: 0.2), value: isSearchFocused)
                            
                            // Netflix-style search button
                            Button(action: search) {
                                HStack(spacing: 6) {
                                    if isLoading {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .tint(.white)
                                    } else {
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 14, weight: .bold))
                                    }
                                    
                                    if !isLoading {
                                        Text("SEARCH")
                                            .font(.system(size: 13, weight: .bold))
                                            .tracking(1)
                                    }
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, isLoading ? 16 : 24)
                                .padding(.vertical, 14)
                                .background(netflixColors.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .disabled(query.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
                                .opacity(query.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1.0)
                            }
                            .buttonStyle(.plain)
                            .animation(.easeInOut(duration: 0.2), value: isLoading)
                        }
                        
                        // Netflix-style filters
                        HStack(spacing: 20) {
                            // Release year filter
                            VStack(alignment: .leading, spacing: 8) {
                                Text("RELEASE YEAR")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white.opacity(0.7))
                                    .tracking(1)
                                
                                TextField("Year", text: $releaseYear)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(netflixDark)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                                    .frame(width: 80)
                            }
                            
                            // Rating filter
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("MIN RATING")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white.opacity(0.7))
                                        .tracking(1)
                                    
                                    Spacer()
                                    
                                    Text("\(minRating, specifier: "%.1f")")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(netflixColors.primary)
                                }
                                
                                Slider(value: $minRating, in: 0...10, step: 0.1)
                                    .tint(netflixColors.primary)
                                    .background(netflixGray)
                            }
                            .frame(maxWidth: 200)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 32)
                
                // Results section
                if showError {
                    ErrorView()
                        .padding(.horizontal, 24)
                } else if results.isEmpty && !query.isEmpty && !isLoading {
                    EmptyStateView(query: query)
                        .padding(.horizontal, 24)
                } else if !results.isEmpty {
                    // Netflix-style results header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SEARCH RESULTS")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white.opacity(0.7))
                                .tracking(1.5)
                            
                            Text("\(results.count) Movies Found")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        if !query.isEmpty {
                            Text("for \"\(query)\"")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .italic()
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                    
                    // Netflix-style results grid
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(results) { movie in
                                NetflixMovieCard(
                                    movie: movie,
                                    netflixColors: netflixColors,
                                    netflixDark: netflixDark,
                                    netflixGray: netflixGray,
                                    isInWatchlist: isInWatchlist(movie),
                                    onMovieTap: { selectedMovie = movie },
                                    onWatchlistToggle: {
                                        if isInWatchlist(movie) {
                                            watchlistManager.remove(movie: movie)
                                        } else {
                                            watchlistManager.add(movie: movie)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                    }
                }
                
                if results.isEmpty && query.isEmpty && !isLoading {
                    NetflixWelcomeView()
                        .padding(.horizontal, 24)
                }
                
                Spacer()
            }
        }
        .sheet(item: $selectedMovie) { movie in
            MovieDetailView(movie: movie) {
                watchlistManager.add(movie: movie)
            }
            .frame(minWidth: 500, minHeight: 600)
        }
    }

    func search() {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        isLoading = true
        showError = false
        results = []

        MovieService.shared.searchMovies(query: query, releaseYear: releaseYear, minRating: minRating) { fetched in
            withAnimation(.easeInOut(duration: 0.5)) {
                isLoading = false
                if fetched.isEmpty && !query.isEmpty {
                    // Handle empty results case
                } else {
                    results = fetched
                }
            }
        }
    }

    func isInWatchlist(_ movie: Movie) -> Bool {
        return watchlistManager.watchlist.contains(where: { $0.id == movie.id })
    }
}

// Netflix-style movie card
struct NetflixMovieCard: View {
    let movie: Movie
    let netflixColors: (primary: Color, secondary: Color, accent: Color)
    let netflixDark: Color
    let netflixGray: Color
    let isInWatchlist: Bool
    let onMovieTap: () -> Void
    let onWatchlistToggle: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onMovieTap) {
            HStack(alignment: .top, spacing: 20) {
                // Netflix-style movie poster
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(netflixGray)
                        .frame(width: 120, height: 180)
                    
                    if let url = movie.posterURL {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        } placeholder: {
                            VStack(spacing: 8) {
                                ProgressView()
                                    .tint(netflixColors.primary)
                                Text("Loading...")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .frame(width: 120, height: 180)
                        }
                    }
                    
                    // Netflix-style play button overlay
                    if isHovered {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.black.opacity(0.7))
                            
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.black)
                                        .offset(x: 2)
                                }
                                
                                Text("PREVIEW")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .tracking(1)
                            }
                        }
                        .frame(width: 120, height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                
                // Netflix-style movie details
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(movie.title)
                            .font(.system(size: 22, weight: .bold, design: .default))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(movie.overview)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(4)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineSpacing(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer(minLength: 20)
                    
                    // Netflix-style action buttons
                    HStack(spacing: 12) {
                        Button(action: onWatchlistToggle) {
                            HStack(spacing: 8) {
                                Image(systemName: isInWatchlist ? "checkmark" : "plus")
                                    .font(.system(size: 12, weight: .bold))
                                
                                Text(isInWatchlist ? "MY LIST" : "MY LIST")
                                    .font(.system(size: 12, weight: .bold))
                                    .tracking(0.5)
                            }
                            .foregroundColor(isInWatchlist ? .black : .white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(isInWatchlist ? .white : Color.white.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.white.opacity(0.3), lineWidth: isInWatchlist ? 0 : 1)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: {}) {
                            Image(systemName: "hand.thumbsup")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(
                                    Circle()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: {}) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(
                                    Circle()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                    }
                }
                .frame(minHeight: 180)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(netflixDark)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                Color.white.opacity(isHovered ? 0.3 : 0.1),
                                lineWidth: 1
                            )
                    )
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .shadow(
                color: Color.black.opacity(isHovered ? 0.4 : 0.2),
                radius: isHovered ? 16 : 8,
                x: 0,
                y: isHovered ? 8 : 4
            )
            .animation(.easeInOut(duration: 0.2), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// Netflix-style welcome view
struct NetflixWelcomeView: View {
    let netflixColors = (primary: Color.red, secondary: Color(red: 0.9, green: 0.9, blue: 0.9), accent: Color(red: 1.0, green: 0.2, blue: 0.2))
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(netflixColors.primary)
                    .frame(width: 80, height: 80)
                
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 12) {
                Text("Discover Movies")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Search through thousands of movies and find your next favorite")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 60)
    }
}

// Netflix-style error view
struct ErrorView: View {
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: 60, height: 60)
                
                Image(systemName: "exclamationmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                Text("Something went wrong")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Text("We couldn't load the search results. Please try again.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }
}

// Netflix-style empty state view
struct EmptyStateView: View {
    let query: String
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "film")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            VStack(spacing: 8) {
                Text("No titles found")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Your search for \"\(query)\" did not have any matches.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                
                Text("Try different keywords or remove search filters.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }
}
