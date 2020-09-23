import Foundation

protocol RequestAdapter {
    func adapt(_ urlRequest: URLRequest) -> Result<URLRequest, Error>
}

open class BaseRequestAdapter: RequestAdapter {
    
    open var baseURL: URL
    
    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    // MARK: - RequestAdapter
    
    public func adapt(_ urlRequest: URLRequest) -> Result<URLRequest, Error> {
        guard let url = urlRequest.url else {
            return .failure(URLError(.badURL))
        }
        
        var request = urlRequest
        request.url = appendingBaseURL(to: url)
        return .success(request)
    }
    
    // MARK: - Private
    
    private func appendingBaseURL(to url: URL) -> URL {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        components.percentEncodedQuery = url.query
        return components.url!.appendingPathComponent(url.path)
    }
}
