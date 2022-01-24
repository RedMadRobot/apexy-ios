import Apexy
import Foundation

struct SimpleUploadEndpoint: UploadEndpoint {
   
    typealias Content = Data
    
    private let data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    func makeRequest() throws -> (URLRequest, UploadEndpointBody) {
        var req = URLRequest(url: URL(string: "upload")!)
        req.httpMethod = "POST"
        
        let body = UploadEndpointBody.data(data)
        return (req, body)
    }
    
    func content(from response: URLResponse?, with body: Data) throws -> Data {
        body
    }
}
