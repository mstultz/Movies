import UIKit
import RxCocoa
import RxSwift

class MoviesViewController: UIViewController, UITableViewDataSource {
    private let configuration = PublishSubject<Configuration>()
    private let disposeBag = DisposeBag()
    private var movieData: [MovieData] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.estimatedRowHeight = MovieCell.estimatedHeight
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(MovieCell.self, forCellReuseIdentifier: MovieCell.identifier)

        self.view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        ])

        let (
            movieData: movieData,
            presentError: presentError,
            updateConfiguration: updateConfiguration
        ) = moviesViewModel(
            configuration: self.configuration,
            viewDidLoad: .just(())
        )

        self.disposeBag.insert([
            movieData
                .observeOn(Current.scheduler)
                .bind(onNext: { [weak self] movieData in
                    guard let strongSelf = self else { return }
                    strongSelf.movieData = movieData
                    tableView.reloadData()
                }),
            presentError
                .observeOn(Current.scheduler)
                .bind(onNext: { [weak self] alertMessage in
                    self?.presentError(alertMessage: alertMessage)
                }),
            updateConfiguration
                .bind(to: self.configuration)
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

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movieData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieCell.identifier, for: indexPath)

        if indexPath.row < self.movieData.count, let movieCell = cell as? MovieCell {
            let movieData = self.movieData[indexPath.row]
            movieCell.configure(with: movieData)
        }

        return cell
    }
}
