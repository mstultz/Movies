import Foundation
@testable import Movies
import RxTest
import XCTest

class TestCase: XCTestCase {
    let scheduler = TestScheduler(initialClock: 0)

    override func setUp() {
        super.setUp()

        Current = .mock
        Current.scheduler = self.scheduler
    }
}
