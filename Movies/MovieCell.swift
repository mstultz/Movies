import RxSwift
import UIKit

private let standardPosterSize = CGSize(width: 24, height: 36)
private let posterScale: CGFloat = 3.0

final class MovieCell: UITableViewCell {
    static let estimatedHeight = standardPosterSize.height * posterScale
    static let identifier = "MovieCell"
    private var disposeBag = DisposeBag()
    private let posterImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let titleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let stackView = UIStackView(arrangedSubviews: [
            self.posterImageView,
            self.titleLabel
        ])
        stackView.spacing = 10.0
        stackView.translatesAutoresizingMaskIntoConstraints = false

        self.contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            self.posterImageView.widthAnchor
                .constraint(equalToConstant: standardPosterSize.width * posterScale),
            self.posterImageView.heightAnchor
                .constraint(equalToConstant: MovieCell.estimatedHeight),
            stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
        self.posterImageView.image = nil
    }

    func configure(with data: MovieData) {
        self.titleLabel.text = data.titleText

        Observable
            .just(data.thumbnailUrl)
            .filterMap { url -> URL? in
                guard let url = url else { return nil }
                return url
            }
            .flatMapLatest { Current.api.image($0) }
            .filterMap { event -> UIImage? in
                guard case let .success(image) = event else { return nil }
                return image
            }
            .observeOn(Current.scheduler)
            .bind(to: self.posterImageView.rx.image)
            .disposed(by: self.disposeBag)
    }
}
