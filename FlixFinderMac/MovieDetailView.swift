import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    var onAddToWatchlist: (() -> Void)?
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Close Button (Top-right)
                HStack {
                    Spacer()
                    Button("Close") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }

                // Movie Poster
                if let url = movie.posterURL {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    } placeholder: {
                        ProgressView()
                            .frame(height: 300)
                    }
                }

                // Movie Title
                Text(movie.title)
                    .font(.title)
                    .fontWeight(.bold)

                // Rating
                if let rating = movie.voteAverage {
                    Text("⭐ Rating: \(String(format: "%.1f", rating))")
                        .font(.subheadline)
                }

                // Release Date
                if let date = movie.releaseDate {
                    Text("🗓 Release: \(date)")
                        .font(.subheadline)
                }

                // Language
                if let lang = movie.originalLanguage {
                    Text("🌍 Language: \(lang.uppercased())")
                        .font(.subheadline)
                }

                // Overview
                Text(movie.overview)
                    .font(.body)
                    .padding(.top, 8)

                // Add to Watchlist
                if let onAdd = onAddToWatchlist {
                    Button("Add to Watchlist") {
                        onAdd()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 20)
                }
            }
            .padding()
        }
        .frame(minWidth: 500, minHeight: 600)
    }
}

