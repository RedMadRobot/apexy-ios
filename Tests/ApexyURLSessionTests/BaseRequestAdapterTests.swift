@testable import ApexyURLSession
import XCTest

final class BaseRequestAdapterTests: XCTestCase {
    
    private let url = URL(string: "https://booklibrary.com")!
    
    private var adapter: RequestAdapter {
        BaseRequestAdapter(baseURL: url)
    }
    
    func testAdaptWhenURLNotContainsTrailingSlash() throws {
        let request = URLRequest(url: URL(string: "books/10")!)
        
        let adaptedRequest = try adapter.adapt(request)
        
        XCTAssertEqual(adaptedRequest.url?.absoluteString, "https://booklibrary.com/books/10")
    }
    
    func testAdaptWhenURLContainsTrailingSlash() throws {
        let request = URLRequest(url: URL(string: "path/")!)
        
        let adaptedRequest = try adapter.adapt(request)
        
        XCTAssertEqual(adaptedRequest.url?.absoluteString, "https://booklibrary.com/path/")
    }
    
    func testAdaptWhenURLContainsQueryItems() throws {
        let url = URL(string: "api/path/")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "param", value: "value")]
        let request = URLRequest(url: components.url!)
        
        let adaptedRequest = try adapter.adapt(request)
        
        XCTAssertEqual(adaptedRequest.url?.absoluteString, "https://booklibrary.com/api/path/?param=value")
    }
    
    func testAdaptWhenRequestContainsHeaders() throws {
        var request = URLRequest(url: URL(string: "books")!)
        request.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        
        let adaptedRequest = try adapter.adapt(request)
        
        XCTAssertEqual(adaptedRequest.value(forHTTPHeaderField: "Content-Type"), "application/octet-stream")
    }
    
}
