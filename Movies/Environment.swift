import Foundation
import RxSwift

private let apiKey = "YOUR_MOVIE_DB_API_KEY"

public struct Environment {
    public var api: ApiClient
    public var scheduler: SchedulerType = MainScheduler.instance
}

extension Environment {
    public init(api: ApiClient) {
        self.api = api
    }
}

public var Current = Environment(
    api: ApiClient(baseUri: "https://api.themoviedb.org/3", apiKey: apiKey)
)
