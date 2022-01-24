import Apexy
import Foundation

/// Loads content by network.
open class WebLoader<Content>: ContentLoader<Content> {
    private let apiClient: Client
    public private(set) var progress: Progress?
    
    /// Creates an instance of `WebLoader` to load content by network using specified `Client`.
    /// - Parameter apiClient: An instance of the `Client` protocol. Use `AlamofireClient` or `URLSessionClient`.
    public init(apiClient: Client) {
        self.apiClient = apiClient
    }

    deinit {
        progress?.cancel()
    }

    /// Sends requests to the network.
    ///
    /// - Warning: You must call `startLoading` before calling this method!
    /// - Parameter endpoint: An object representing request.
    public func request<T>(_ endpoint: T) where T: Endpoint, T.Content == Content {
        progress = apiClient.request(endpoint) { [weak self] result in
            self?.progress = nil
            self?.finishLoading(result)
        }
    }

    /// Sends requests to the network and transform successfull result
    ///
    /// - Parameters:
    ///   - endpoint: An object representing request.
    ///   - transform: A closure that transforms successfull result.
    public func request<T>(_ endpoint: T, transform: @escaping (T.Content) -> Content) where T: Endpoint {
        progress = apiClient.request(endpoint) { [weak self] result in
            self?.progress = nil
            self?.finishLoading(result.map(transform))
        }
    }
    
    /// Sends requests to the network and calls completion handler.
    /// - Parameters:
    ///   - endpoint: An object representing request.
    ///   - completion: A completion handler.
    public func request<T>(_ endpoint: T, completion: @escaping (Result<T.Content, Error>) -> Void) where T: Endpoint {
        progress = apiClient.request(endpoint) { [weak self] result in
            self?.progress = nil
            completion(result)
        }
    }
}
