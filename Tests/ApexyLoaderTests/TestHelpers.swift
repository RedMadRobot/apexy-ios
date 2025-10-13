import Apexy
import Foundation

// MARK: - Mock Client

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
final class MockClient: Client {
    var mockResult: Result<String, Error> = .success("Mock Content")
    
    func request<T>(_ endpoint: T) async throws -> T.Content where T: Endpoint {
        switch mockResult {
        case .success(let content):
            return content as! T.Content
        case .failure(let error):
            throw error
        }
    }
    
    func upload<T>(_ endpoint: T) async throws -> T.Content where T: UploadEndpoint {
        switch mockResult {
        case .success(let content):
            return content as! T.Content
        case .failure(let error):
            throw error
        }
    }
}

// MARK: - Mock Endpoint

struct MockEndpoint: Endpoint {
    typealias Content = String
    
    func makeRequest() throws -> URLRequest {
        return URLRequest(url: URL(string: "https://example.com")!)
    }
    
    func content(from response: URLResponse?, with body: Data) throws -> Content {
        return String(data: body, encoding: .utf8) ?? ""
    }
    
    func validate(_ request: URLRequest?, response: HTTPURLResponse, data: Data?) throws {
        // No validation needed for tests
    }
}
