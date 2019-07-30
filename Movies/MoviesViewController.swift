import UIKit
import RxCocoa
import RxSwift

class MoviesViewController: UIViewController {
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        let (
            movieData: movieData,
            presentError: presentError
        ) = moviesViewModel(
            viewDidLoad: .just(())
        )

        self.disposeBag.insert([
            movieData
                .observeOn(Current.scheduler)
                .bind(onNext: { movieData in
                    print(movieData)
                }),
            presentError
                .observeOn(Current.scheduler)
                .bind(onNext: { [weak self] alertMessage in
                    self?.presentError(alertMessage: alertMessage)
                }),
        ])
    }

    private func presentError(alertMessage: AlertMessage) {
        let vc = UIAlertController(
            title: alertMessage.title,
            message: alertMessage.message,
            preferredStyle: .alert
        )
        vc.addAction(.init(title: "OK", style: .default, handler: nil))
        present(vc, animated: true, completion: nil)
    }
}
