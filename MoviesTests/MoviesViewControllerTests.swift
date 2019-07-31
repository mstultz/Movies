@testable import Movies
import SnapshotTesting

class MoviesViewControllerTests: TestCase {
    override func setUp() {
        super.setUp()
        record = true
    }

    func testDefault() {
        UIView.performWithoutAnimation {
            let snaps: [String: (CGSize, UITraitCollection)] = [
                "iphone-se": (.init(width: 320, height: 568), .iPhoneSe(.portrait)),
                "iphone-8": (.init(width: 375, height: 667), .iPhone8(.portrait)),
                "iphone-x": (.init(width: 375, height: 812), .iPhoneX(.portrait))
            ]
            for (label, config) in snaps {
                let (size, traits) = config
                let vc = MoviesViewController()
                vc.view.frame = CGRect(origin: .zero, size: size)
                self.scheduler.advanceTo(self.scheduler.clock + 1)
                vc.view.layoutIfNeeded()
                self.scheduler.advanceTo(self.scheduler.clock + 1)

                assertSnapshot(matching: vc, as: .image(size: size, traits: traits), named: label)
            }
        }
    }
}
