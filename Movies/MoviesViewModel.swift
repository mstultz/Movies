import Foundation
import RxSwift

struct AlertMessage: Equatable {
    let message: String
    let title: String
}

struct MovieData: Equatable {
    let thumbnailUrl: URL?
    let titleText: String
}

func moviesViewModel(
    configuration: Observable<Configuration>,
    viewDidLoad: Observable<Void>
) -> (
    movieData: Observable<[MovieData]>,
    presentError: Observable<AlertMessage>,
    updateConfiguration: Observable<Configuration>
) {
    let configurationResponse = viewDidLoad
        .flatMapLatest { Current.api.configuration }

    let currentConfiguration = configurationResponse
        .filterMap { event -> Configuration? in
            guard case let .success(response) = event else { return nil }
            return response
        }

    let updateConfiguration = currentConfiguration

    let configurationError = configurationResponse
        .filterMap { event -> ApiError? in
            guard case let .failure(error) = event else { return nil }
            return error
        }

    let topMoviesResponse = configuration
        .flatMapLatest { _ in Current.api.topMovies(1) }

    let topMovies = topMoviesResponse
        .filterMap { event -> MoviesResponse? in
            guard case let .success(response) = event else { return nil }
            return response
        }

    let movieData = topMovies
        .withLatestFrom(configuration) { ($1, $0) }
        .map { configuration, movieResponse -> [MovieData] in
            let thumbnailSize = configuration.images.posterSizes.first ?? ""
            return movieResponse.results.map {
                MovieData(
                    thumbnailUrl: configuration
                        .images
                        .secureBaseUrl
                        .appendingPathComponent(thumbnailSize)
                        .appendingPathComponent($0.posterPath),
                    titleText: $0.title
                )
            }
        }

    let topMoviesError = topMoviesResponse
        .filterMap{ event -> ApiError? in
            guard case let .failure(error) = event else { return nil }
            return error
        }

    let errors = Observable.merge(
        configurationError,
        topMoviesError
    )

    let presentError = errors.map { error -> AlertMessage in
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
        presentError: presentError,
        updateConfiguration: updateConfiguration
    )
}
