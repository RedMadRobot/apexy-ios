import Foundation

/// A type that can inspect and optionally adapt a `URLRequest` in some manner if necessary.
public protocol RequestAdapter {
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest
}

/// A type that adapt a `URLRequest` by appending base URL.
open class BaseRequestAdapter: RequestAdapter {
    
    /// Contains Base `URL`.
    ///
    /// Must end with a slash character `https://example.com/api/v1/`
    ///
    /// - Warning: declared as open variable for debug purposes only.
    open var baseURL: URL
    
    /// Creates a `BaseRequestAdapter` instance with specified Base `URL`.
    ///
    /// - Parameter baseURL: Base `URL` for adapter.
    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    // MARK: - RequestAdapter
    
    open func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        guard let url = urlRequest.url else {
            throw URLError(.badURL)
        }
        
        var request = urlRequest
        request.url = appendingBaseURL(to: url)
        return request
    }
    
    // MARK: - Private
    
    private func appendingBaseURL(to url: URL) -> URL {
        URL(string: url.absoluteString, relativeTo: baseURL)!
    }
}
