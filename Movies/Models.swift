import Foundation

public struct Movie: Codable {
    public let id: Int
    public let overview: String
    public let releaseDate: Date
    public let title: String
    public let voteAverage: Double
    public let voteCount: Int

    private enum CodingKeys: String, CodingKey {
        case id
        case overview
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
