import Foundation
import RxSwift

struct AlertMessage {
    let message: String
    let title: String
}

struct MovieData {
    let title: String
}

func moviesViewModel(
    viewDidLoad: Observable<Void>
) -> (
    movieData: Observable<[MovieData]>,
    presentError: Observable<AlertMessage>
) {

    let topMoviesResponse = viewDidLoad
        .flatMapLatest { Current.api.topMovies(1) }

    let topMovies = topMoviesResponse
        .map { event -> MoviesResponse? in
            guard case let .success(response) = event else { return nil }
            return response
        }
        .filter { $0 != nil }
        .map { $0! }

    let movieData = topMovies
        .map {
            $0.results.map { MovieData(title: $0.title) }
        }

    let topMoviesError = topMoviesResponse
        .map { event -> ApiError? in
            guard case let .failure(error) = event else { return nil }
            return error
        }
        .filter { $0 != nil }
        .map { $0! }

    let presentError = topMoviesError.map { error -> AlertMessage in
        switch error {
        case .decodeFailed:
            return AlertMessage(message: "Failed to decode response", title: "An error occurred")
        case .invalidResponse:
            return AlertMessage(message: "The response was invalid", title: "An error occurred")
        case .invalidUrl:
            return AlertMessage(message: "The URL was invalid", title: "An error occurred")
        }
    }

    return (
        movieData: movieData,
        presentError: presentError
    )
}
