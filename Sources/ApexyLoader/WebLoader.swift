import Apexy
import Foundation

/// Loads content by network.
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
open class WebLoader<Content>: ContentLoader<Content> {
    private let apiClient: Client
    
    /// Creates an instance of `WebLoader` to load content by network using specified `Client`.
    /// - Parameter apiClient: An instance of the `Client` protocol. Use `AlamofireClient` or `URLSessionClient`.
    public init(apiClient: Client) {
        self.apiClient = apiClient
    }

    /// Sends requests to the network.
    ///
    /// - Warning: You must call `startLoading` before calling this method!
    /// - Parameter endpoint: An object representing request.
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public func request<T>(_ endpoint: T) async where T: Endpoint, T.Content == Content {
        do {
            let content = try await apiClient.request(endpoint)
            finishLoading(.success(content))
        } catch {
            finishLoading(.failure(error))
        }
    }

    /// Sends requests to the network and transform successfull result
    ///
    /// - Parameters:
    ///   - endpoint: An object representing request.
    ///   - transform: A closure that transforms successfull result.
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public func request<T>(_ endpoint: T, transform: @escaping (T.Content) -> Content) async where T: Endpoint {
        do {
            let content = try await apiClient.request(endpoint)
            finishLoading(.success(transform(content)))
        } catch {
            finishLoading(.failure(error))
        }
    }
    
    /// Sends requests to the network and calls completion handler.
    /// - Parameters:
    ///   - endpoint: An object representing request.
    ///   - completion: A completion handler.
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public func request<T>(_ endpoint: T, completion: @escaping (Result<T.Content, Error>) -> Void) async where T: Endpoint {
        do {
            let content = try await apiClient.request(endpoint)
            completion(.success(content))
        } catch {
            completion(.failure(error))
        }
    }
    
}
