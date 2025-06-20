import Foundation

class MovieService {
    static let shared = MovieService()
    private let baseURL = "https://api.themoviedb.org/3"
    private let accessToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI3ZTNlY2U0ZGVlNmY0N2E2ZjJiYWNlOTY3ZGQwZmEwYSIsIm5iZiI6MTc0MTMyOTEyMS41ODYsInN1YiI6IjY3Y2E5MmUxZGJhMTQ5MTYwNjJiNDkxNyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.BWb1RzGZ3df3TuQ3IacGPsx3cb--XPLmy8f8bzQnJpw" // Replace with your actual token

    func searchMovies(query: String, releaseYear: String?, minRating: Double, completion: @escaping ([Movie]) -> Void) {
        var urlComponents = URLComponents(string: "\(baseURL)/search/movie")!
        var queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "vote_average.gte", value: String(minRating)),
            URLQueryItem(name: "include_adult", value: "false"),
            URLQueryItem(name: "sort_by", value: "popularity.desc")
        ]

        // Add release year if valid
        if let year = releaseYear, !year.isEmpty, let intYear = Int(year) {
            queryItems.append(URLQueryItem(name: "primary_release_year", value: String(intYear)))
        }

        urlComponents.queryItems = queryItems

        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let result = try JSONDecoder().decode(MovieResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(result.results)
                    }
                } catch {
                    print("Decoding error:", error)
                    DispatchQueue.main.async {
                        completion([])
                    }
                }
            } else {
                print("Network error:", error ?? "Unknown")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }.resume()
    }

    func fetchMovies(for genreID: Int, completion: @escaping ([Movie]) -> Void) {
        var urlComponents = URLComponents(string: "\(baseURL)/discover/movie")!
        urlComponents.queryItems = [
            URLQueryItem(name: "with_genres", value: String(genreID)),
            URLQueryItem(name: "sort_by", value: "popularity.desc")
        ]

        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let result = try JSONDecoder().decode(MovieResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(result.results)
                    }
                } catch {
                    print("Decoding error:", error)
                    DispatchQueue.main.async {
                        completion([])
                    }
                }
            } else {
                print("Network error:", error ?? "Unknown")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }.resume()
    }
}

