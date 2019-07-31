import CommonCrypto
import Foundation
@testable import Movies
import RxTest

func hashSha1(_ string: String) -> String? {
    guard let data = string.data(using: .utf8) else { return nil }
    var digest = Data(count: Int(CC_SHA1_DIGEST_LENGTH))
    _ = digest.withUnsafeMutableBytes { digestBytes -> UInt8 in
        data.withUnsafeBytes { dataBytes -> UInt8 in
            guard
                let dataByte = dataBytes.baseAddress,
                let digestByte = digestBytes.bindMemory(to: UInt8.self).baseAddress
                else { return 0 }
            let length = CC_LONG(string.count)
            CC_SHA1(dataByte, length, digestByte)
            return 0
        }
    }
    return digest.map { String(format: "%02hhx", $0) }.joined()
}

extension ApiClient {
    static let mock = ApiClient(
        configuration: .just(.success(.mock)),
        image: {
            let size = CGSize(width: 500, height: 500)
            var startColor = UIColor.white.cgColor
            var endColor = UIColor.black.cgColor

            if let hash = hashSha1($0.absoluteString) {
                let colors: [UIColor] = [.red, .green, .blue, .cyan, .yellow, .magenta, .orange, .purple]
                startColor = colors[Int(hash.utf8CString[0]) % colors.count].cgColor
                endColor = colors[Int(hash.utf8CString[1]) % colors.count].cgColor
            }

            let gradient = CAGradientLayer()
            gradient.frame = CGRect(origin: .zero, size: size)
            gradient.colors = [startColor, endColor]

            let renderer = UIGraphicsImageRenderer(size: size)
            let image = renderer.image { gradient.render(in: $0.cgContext) }
            return .just(.success(image))
        },
        topMovies: { _ in .just(.success(.mock)) },
        worstMovies: { _ in .just(.success(.mock)) }
    )
}

extension URL {
    static let mock = URL(string: "https://www.mark.wtf/")!
}

extension Configuration {
    static let mock = Configuration(
        images: Configuration.Images(
            backdropSizes: ["100"],
            baseUrl: .mock,
            logoSizes: ["100"],
            posterSizes: ["100"],
            profileSizes: ["100"],
            secureBaseUrl: .mock,
            stillSizes: ["100"]
        )
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
        posterPath: "posterOne",
        releaseDate: .mock,
        title: "A New Hope",
        voteAverage: 0.6,
        voteCount: 10
    )
    static let mockTwo = Movie(
        id: 1,
        overview: "A bad movie",
        posterPath: "posterTwo",
        releaseDate: .mock,
        title: "The Empire Strikes Back",
        voteAverage: 0.7,
        voteCount: 6
    )
    static let mockThree = Movie(
        id: 2,
        overview: "An ugly movie",
        posterPath: "posterThree",
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
