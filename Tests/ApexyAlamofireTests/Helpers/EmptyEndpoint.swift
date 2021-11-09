import Apexy
import Foundation

struct EmptyEndpoint: Endpoint {
    
    typealias Content = Data
    
    func makeRequest() throws -> URLRequest {
        URLRequest(url: URL(string: "empty")!)
    }
    
    func content(from response: URLResponse?, with body: Data) throws -> Data {
        return body
    }
}
