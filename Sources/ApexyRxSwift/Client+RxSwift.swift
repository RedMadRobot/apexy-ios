import Apexy
import RxSwift

public extension Client {
    
    func request<T>(_ endpoint: T) -> Single<T.Content> where T: Endpoint {
        Single.create { single in
            let progress = self.request(endpoint) { (result: Result<T.Content, Error>) in
                single(result)
            }
            return Disposables.create(with: progress.cancel)
        }
    }
}
