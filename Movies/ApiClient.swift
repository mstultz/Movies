import Foundation
import RxSwift

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
}()

private let jsonDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(dateFormatter)
    return decoder
}()

public enum ApiError: Error {
    case decodeFailed
    case invalidResponse
    case invalidUrl
}

public struct ApiClient {
    public var topMovies: (Int) -> Observable<Result<MoviesResponse, ApiError>>
    public var worstMovies: (Int) -> Observable<Result<MoviesResponse, ApiError>>
}

extension ApiClient {
    public init(baseUri: String, apiKey: String) {
        let client = _Client(baseUri: baseUri, apiKey: apiKey)
        self = .init(
            topMovies: { page in
                let queryItems = ["page": String(max(1, page)), "sort_by": "popularity.desc"]
                return client.resource(request: .get("discover/movie", queryItems: queryItems))
            },
            worstMovies: { page in
                let queryItems = ["page": String(max(1, page)), "sort_by": "popularity.asc"]
                return client.resource(request: .get("discover/movie", queryItems: queryItems))
            }
        )
    }
}

fileprivate struct Request {
    var httpMethod: String
    var queryItems: [String: String?]
    var uri: String

    static func get(_ uri: String, queryItems: [String: String?] = [:]) -> Request {
        return Request(httpMethod: "GET", queryItems: queryItems, uri: uri)
    }
}

private class _Client {
    let apiKey: String
    let baseUri: String
    let urlSession = URLSession(configuration: .default)

    init(baseUri: String, apiKey: String) {
        self.apiKey = apiKey
        self.baseUri = baseUri
    }

    func resource<Resource>(request: Request) -> Observable<Result<Resource, ApiError>> where Resource: Decodable {
        return response(request: request).map { data -> Result<Resource, ApiError> in
            do {
                let resource = try jsonDecoder.decode(Resource.self, from: data)
                return .success(resource)
            } catch _ {
                return .failure(.invalidResponse)
            }
        }
    }

    func response(request: Request) -> Observable<Data> {
        return Observable<Data>.create { observer in
            var urlComponents = URLComponents(string: "\(self.baseUri)/\(request.uri)")
            urlComponents?.queryItems = [URLQueryItem(name: "api_key", value: self.apiKey)] +
                request.queryItems.map { URLQueryItem(name: $0, value: $1) }

            if let url = urlComponents?.url {
                var request = URLRequest(url: url)
                request.httpMethod = request.httpMethod

                self.urlSession
                    .dataTask(with: request, completionHandler: { data, response, error in
                        if let data = data {
                            observer.onNext(data)
                        } else {
                            observer.onError(ApiError.invalidResponse)
                        }
                    })
                    .resume()
            } else {
                observer.onError(ApiError.invalidUrl)
            }

            return Disposables.create()
        }
    }
}
