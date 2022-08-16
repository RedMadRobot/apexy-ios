#if canImport(Combine)
import Combine

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public protocol CombineClient: AnyObject {
    
    /// Send request to specified endpoint.
    /// - Parameters:
    ///    - endpoint: endpoint of remote content.
    /// - Returns: Publisher which you can subscribe to
    func request<T>(_ endpoint: T) -> AnyPublisher<T.Content, Error> where T: Endpoint
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension Client where Self: CombineClient {
    func request<T>(_ endpoint: T) -> AnyPublisher<T.Content, Error> where T: Endpoint {
        Deferred<AnyPublisher<T.Content, Error>> {
            let subject = PassthroughSubject<T.Content, Error>()
            
            let progress = self.request(endpoint) { (result: Result<T.Content, Error>) in
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
        .eraseToAnyPublisher()
    }
}

#endif
