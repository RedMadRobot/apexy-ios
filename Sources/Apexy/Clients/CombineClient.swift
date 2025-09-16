#if canImport(Combine)
import Combine

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public protocol CombineClient: AnyObject {
    
    /// Send request to specified endpoint.
    /// - Parameters:
    ///    - endpoint: endpoint of remote content.
    /// - Returns: Publisher which you can subscribe to
    func request<T>(_ endpoint: T) -> AnyPublisher<T.Content, Error> where T: Endpoint
    
    /// Upload data to specified endpoint.
    /// - Parameters:
    ///    - endpoint: endpoint of remote content.
    /// - Returns: Publisher which you can subscribe to
    func upload<T>(_ endpoint: T) -> AnyPublisher<T.Content, Error> where T: UploadEndpoint
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension Client where Self: CombineClient {
    func request<T>(_ endpoint: T) -> AnyPublisher<T.Content, Error> where T: Endpoint {
        Future<T.Content, Error> { promise in
            Task {
                do {
                    let content = try await self.request(endpoint)
                    promise(.success(content))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func upload<T>(_ endpoint: T) -> AnyPublisher<T.Content, Error> where T: UploadEndpoint {
        Future<T.Content, Error> { promise in
            Task {
                do {
                    let content = try await self.upload(endpoint)
                    promise(.success(content))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

#endif
