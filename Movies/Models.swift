import Foundation

public struct Configuration: Codable, Equatable {
    public let images: Images

    public struct Images: Codable, Equatable {
        public let backdropSizes: [String]
        public let baseUrl: URL
        public let logoSizes: [String]
        public let posterSizes: [String]
        public let profileSizes: [String]
        public let secureBaseUrl: URL
        public let stillSizes: [String]

        private enum CodingKeys: String, CodingKey {
            case backdropSizes = "backdrop_sizes"
            case baseUrl = "base_url"
            case logoSizes = "logo_sizes"
            case posterSizes = "poster_sizes"
            case profileSizes = "profile_sizes"
            case secureBaseUrl = "secure_base_url"
            case stillSizes = "still_sizes"
        }
    }
}

public struct Movie: Codable {
    public let id: Int
    public let overview: String
    public let posterPath: String
    public let releaseDate: Date
    public let title: String
    public let voteAverage: Double
    public let voteCount: Int

    private enum CodingKeys: String, CodingKey {
        case id
        case overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case title
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}

public struct MoviesResponse: Codable {
    public let page: Int
    public let totalPages: Int
    public let totalResults: Int
    public let results: [Movie]

    private enum CodingKeys: String, CodingKey {
        case page
        case totalPages = "total_pages"
        case totalResults = "total_results"
        case results
    }
}
