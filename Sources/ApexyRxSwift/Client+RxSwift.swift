import Apexy
import RxSwift

public extension Client {
    
    func request<T>(_ endpoint: T) -> Single<T.Content> where T: Endpoint {
        Single.create { single in
            let progress = self.request(endpoint) { (result: Result<T.Content, Error>) in
                switch result {
                case .success(let content):
                    single(.success(content))
                case .failure(let error):
                    single(.error(error))
                }
            }
            return Disposables.create(with: progress.cancel)
        }
    }
}
