#if canImport(Combine)
import Combine
#endif

public extension Client {
    
    @available(iOS 13.0, *)
    func request<T>(_ endpoint: T) -> AnyPublisher<T.Content, Error> where T: Endpoint {
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
}
