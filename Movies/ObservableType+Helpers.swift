import Foundation
import RxSwift

extension ObservableType {
    func filterMap<T>(_ transform: @escaping (E) -> T?) -> Observable<T> {
        return map(transform)
            .filter { $0 != nil }
            .map { $0! }
    }
}
