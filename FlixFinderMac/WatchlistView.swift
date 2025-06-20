import SwiftUI

struct WatchlistView: View {
    @ObservedObject var watchlistManager: WatchlistManager
    @State private var selectedMovie: Movie? = nil

    var body: some View {
        ZStack {
            // Netflix black background
            Color.black
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Header
                NetflixWatchlistHeader(
                    movieCount: watchlistManager.watchlist.count,
                    watchlistManager: watchlistManager
                )
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 32)

                if watchlistManager.watchlist.isEmpty {
                    NetflixEmptyWatchlistView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 16) {
                            ForEach(watchlistManager.watchlist) { movie in
                                NetflixWatchlistMovieCard(
                                    movie: movie,
                                    watchlistManager: watchlistManager,
                                    onRemove: {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            watchlistManager.remove(movie: movie)
                                        }
                                    },
                                    onTap: {
                                        selectedMovie = movie
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }

                Spacer(minLength: 0)
            }
        }
        .sheet(item: $selectedMovie) { movie in
            NetflixMovieDetailView(movie: movie) {
                // Already in watchlist, so we don't need to add again
            }
        }
    }
}

// MARK: - Netflix Watchlist Header
struct NetflixWatchlistHeader: View {
    let movieCount: Int
    let watchlistManager: WatchlistManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("My List")
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(.white)
                    
                    if movieCount > 0 {
                        Text("\(movieCount) \(movieCount == 1 ? "title" : "titles")")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Spacer()
                
                // Share entire watchlist button
                if movieCount > 0 {
                    ShareLink(
                        item: watchlistManager.getWatchlistSummary(),
                        subject: Text("My Movie Watchlist"),
                        message: Text("Check out my movie watchlist!")
                    ) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
                
                // Netflix-style "N" logo
                Text("N")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.red)
                    .cornerRadius(6)
            }
            
            if movieCount > 0 {
                // Download and Sort options (Netflix style)
                HStack(spacing: 24) {
                    Button(action: {}) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.down.circle")
                                .font(.system(size: 20))
                            Text("")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {}) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.system(size: 20))
                            Text("")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)
                    
                    // Share top rated movies button
                    ShareLink(
                        item: watchlistManager.getTopRatedMoviesForSharing(),
                        subject: Text("Top Movies from My Watchlist"),
                        message: Text("Here are some great movies from my watchlist!")
                    ) {
                        HStack(spacing: 8) {
                            Image(systemName: "star.circle")
                                .font(.system(size: 20))
                            Text("Share Top")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Netflix Empty Watchlist View
struct NetflixEmptyWatchlistView: View {
    var body: some View {
        VStack(spacing: 24) {
            // Netflix-style empty state icon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "plus.circle")
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            VStack(spacing: 12) {
                Text("Your list is empty")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Add movies and shows to your list to\nwatch them later.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            
            // Browse button
            Button(action: {}) {
                Text("Browse Movies")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(4)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 40)
    }
}

// MARK: - Netflix Watchlist Movie Card
struct NetflixWatchlistMovieCard: View {
    let movie: Movie
    let watchlistManager: WatchlistManager
    let onRemove: () -> Void
    let onTap: () -> Void
    
    @State private var showingRemoveAlert = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 16) {
                // Movie poster
                if let url = movie.posterURL {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(2/3, contentMode: .fill)
                            .frame(width: 100, height: 150)
                            .clipped()
                            .cornerRadius(8)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 100, height: 150)
                            .cornerRadius(8)
                            .overlay(
                                ProgressView()
                                    .tint(.red)
                            )
                    }
                }
                
                // Movie details
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(movie.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(movie.overview)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Action buttons
                    HStack(spacing: 16) {
                        Button(action: onTap) {
                            HStack(spacing: 6) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 14))
                                Text("Play")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .cornerRadius(4)
                        }
                        .buttonStyle(.plain)
                        
                        // Share button using macOS share sheet
                        ShareLink(
                            item: watchlistManager.createShareableContent(for: movie),
                            subject: Text("Check out this movie: \(movie.title)"),
                            message: Text("I found this movie on my watchlist and thought you might like it!")
                        ) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: {
                            showingRemoveAlert = true
                        }) {
                            Image(systemName: "minus.circle")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .alert("Remove from My List", isPresented: $showingRemoveAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                onRemove()
            }
        } message: {
            Text("Are you sure you want to remove \"\(movie.title)\" from your list?")
        }
    }
}

// Note: NetflixMovieDetailView should be defined in MovieListView.swift or MovieDetailView.swift
