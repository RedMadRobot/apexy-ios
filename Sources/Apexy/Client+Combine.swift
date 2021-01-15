#if canImport(Combine)
import Combine

/// Wrapper for Combine framework
public extension Client {

    @available(iOS 13.0, *)
    @available(macOS 10.15, *)
    @available(tvOS 13.0, *)
    @available(watchOS 6.0, *)
    func request<T>(_ endpoint: T) -> AnyPublisher<T.Content, T.ErrorType> where T: Endpoint {
        let subject = PassthroughSubject<T.Content, T.ErrorType>()
        
        let progress = self.request(endpoint) { (result: Result<T.Content, T.ErrorType>) in
            switch result {
            case .success(let content):
                subject.send(content)
                subject.send(completion: .finished)
            case .failure(let error):
                subject.send(completion: .failure(error))
            }
        }
        
        return subject.handleEvents(receiveCancel: {
            progress.cancel()
            subject.send(completion: .finished)
        }).eraseToAnyPublisher()
    }
}
#endif
