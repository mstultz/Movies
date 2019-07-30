@testable import Movies
import RxSwift
import RxTest
import SnapshotTesting
import XCTest

class MoviesViewModelTests: TestCase {
    // Inputs
    let viewDidLoad = PublishSubject<Void>()

    // Outputs
    lazy var movieData = self.scheduler.createObserver([MovieData].self)
    lazy var presentError = self.scheduler.createObserver(AlertMessage.self)

    override func setUp() {
        super.setUp()

        let (
            movieData: movieData,
            presentError: presentError
        ) = moviesViewModel(
            viewDidLoad: self.viewDidLoad
        )

        _ = movieData.subscribe(self.movieData)
        _ = presentError.subscribe(self.presentError)
    }

    func testMovieData() {
        self.viewDidLoad.onNext(())

        XCTAssertEqual(
            self.movieData.events,
            [
                next(0, [
                    MovieData(title: "A New Hope"),
                    MovieData(title: "The Empire Strikes Back"),
                    MovieData(title: "Return of the Jedi"),
                ])
            ]
        )
    }

    func testPresentError() {
        Current.api.topMovies = { _ in .just(.failure(.invalidUrl)) }

        self.viewDidLoad.onNext(())

        XCTAssertEqual(
            self.presentError.events,
            [next(0, AlertMessage(message: "The URL was invalid", title: "An error occurred"))]
        )
    }
}
