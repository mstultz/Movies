@testable import Movies
import RxSwift
import RxTest
import SnapshotTesting
import XCTest

class MoviesViewModelTests: TestCase {
    // Inputs
    let configuration = PublishSubject<Configuration>()
    let viewDidLoad = PublishSubject<Void>()

    // Outputs
    lazy var movieData = self.scheduler.createObserver([MovieData].self)
    lazy var presentError = self.scheduler.createObserver(AlertMessage.self)
    lazy var updateConfiguration = self.scheduler.createObserver(Configuration.self)

    override func setUp() {
        super.setUp()

        let (
            movieData: movieData,
            presentError: presentError,
            updateConfiguration: updateConfiguration
        ) = moviesViewModel(
            configuration: self.configuration,
            viewDidLoad: self.viewDidLoad
        )

        _ = movieData.subscribe(self.movieData)
        _ = presentError.subscribe(self.presentError)
        _ = updateConfiguration.subscribe(self.updateConfiguration)
    }

    func testMovieData() {
        XCTAssertEqual(self.updateConfiguration.events.count, 0)

        self.viewDidLoad.onNext(())

        XCTAssertEqual(self.updateConfiguration.events, [next(0, Configuration.mock)])

        self.configuration.onNext(.mock)

        XCTAssertEqual(
            self.movieData.events,
            [
                next(0, [
                    MovieData(
                        thumbnailUrl: URL.mock.appendingPathComponent("100/posterOne"),
                        titleText: "A New Hope"
                    ),
                    MovieData(
                        thumbnailUrl: URL.mock.appendingPathComponent("100/posterTwo"),
                        titleText: "The Empire Strikes Back"
                    ),
                    MovieData(
                        thumbnailUrl: URL.mock.appendingPathComponent("100/posterThree"),
                        titleText: "Return of the Jedi"
                    )
                ])
            ]
        )
    }

    func testPresentError() {
        Current.api.topMovies = { _ in .just(.failure(.invalidUrl)) }

        self.viewDidLoad.onNext(())
        self.configuration.onNext(.mock)

        XCTAssertEqual(
            self.presentError.events,
            [next(0, AlertMessage(message: "The URL was invalid", title: "An error occurred"))]
        )
    }
}
