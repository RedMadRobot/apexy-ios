#if canImport(Combine)
import Combine
import Apexy
import ApexyAlamofire
import XCTest

final class AlamofireClientCombineTests: XCTestCase {
    
    private var client: AlamofireClient!
    private var cancellables = Set<AnyCancellable>()
    
    override func setUp() {
        let url = URL(string: "https://booklibrary.com")!
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        
        client = AlamofireClient(baseURL: url, configuration: config)
    }
    
    func testClientRequestWithCombineMultipleTimes() {
        let endpoint = EmptyEndpoint()
        MockURLProtocol.requestHandler = { request in
            let data = UUID().uuidString.data(using: .utf8)!
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "2.0", headerFields: nil)!
            return (response, data)
        }
        
        let exp = expectation(description: "wait for response")
        exp.expectedFulfillmentCount = 2
        
        // First request
        var firstRequestContent: Data?
        client.request(endpoint)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { content in
                    firstRequestContent = content
                    exp.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Second request
        var secondRequestContent: Data?
        client.request(endpoint)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { content in
                    secondRequestContent = content
                    exp.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Third request which will be cancelled at once
        client.request(endpoint)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in }
            )
            .cancel()
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertNotNil(firstRequestContent)
        XCTAssertNotNil(secondRequestContent)
        XCTAssertNotEqual(firstRequestContent, secondRequestContent)
    }
}
#endif
