import Foundation

protocol RequestAdapter {
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest
}

open class BaseRequestAdapter: RequestAdapter {
    
    open var baseURL: URL
    
    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    // MARK: - RequestAdapter
    
    public func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
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
