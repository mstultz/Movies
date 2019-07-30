import Foundation
@testable import Movies
import RxTest

extension ApiClient {
    static let mock = ApiClient(
        topMovies: { _ in .just(.success(.mock)) },
        worstMovies: { _ in .just(.success(.mock)) }
    )
}

extension Date {
    static let mock = Date(timeIntervalSince1970: 0)
}

extension Environment {
    static let mock = Environment(
        api: .mock,
        scheduler: TestScheduler(initialClock: 0)
    )
}

extension Movie {
    static let mockOne = Movie(
        id: 0,
        overview: "A good movie",
        releaseDate: .mock,
        title: "A New Hope",
        voteAverage: 0.6,
        voteCount: 10
    )
    static let mockTwo = Movie(
        id: 1,
        overview: "A bad movie",
        releaseDate: .mock,
        title: "The Empire Strikes Back",
        voteAverage: 0.7,
        voteCount: 6
    )
    static let mockThree = Movie(
        id: 2,
        overview: "An ugly movie",
        releaseDate: .mock,
        title: "Return of the Jedi",
        voteAverage: 0.55,
        voteCount: 12
    )
}

extension MoviesResponse {
    static let mock = MoviesResponse(
        page: 1,
        totalPages: 1,
        totalResults: 3,
        results: [
            .mockOne,
            .mockTwo,
            .mockThree
        ]
    )
}
