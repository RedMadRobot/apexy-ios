@testable import ApexyLoader
import Apexy
import XCTest

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
final class WebLoaderTests: XCTestCase {
    
    private var mockClient: MockClient!
    private var webLoader: WebLoader<String>!
    
    override func setUp() {
        super.setUp()
        mockClient = MockClient()
        webLoader = WebLoader(apiClient: mockClient)
    }
    
    override func tearDown() {
        webLoader = nil
        mockClient = nil
        super.tearDown()
    }
    
    // MARK: - Async Request Tests
    
    func testAsyncRequestSuccess() async {
        // Given
        let expectedContent = "Test Content"
        mockClient.mockResult = .success(expectedContent)
        let endpoint = MockEndpoint()
        
        // When
        guard webLoader.startLoading() else {
            XCTFail("Should be able to start loading")
            return
        }
        
        await webLoader.request(endpoint)
        
        // Then
        switch webLoader.state {
        case .success(let content):
            XCTAssertEqual(content, expectedContent)
        default:
            XCTFail("Expected success state, got \(webLoader.state)")
        }
    }
    
    func testAsyncRequestFailure() async {
        // Given
        let expectedError = URLError(.networkConnectionLost)
        mockClient.mockResult = .failure(expectedError)
        let endpoint = MockEndpoint()
        
        // When
        guard webLoader.startLoading() else {
            XCTFail("Should be able to start loading")
            return
        }
        
        await webLoader.request(endpoint)
        
        // Then
        switch webLoader.state {
        case .failure(let error, let cache):
            XCTAssertEqual(error as? URLError, expectedError)
            XCTAssertNil(cache)
        default:
            XCTFail("Expected failure state, got \(webLoader.state)")
        }
    }
    
    func testAsyncRequestWithTransformation() async {
        // Given
        let rawContent = "Raw Content"
        let transformedContent = "Transformed: Raw Content"
        mockClient.mockResult = .success(rawContent)
        let endpoint = MockEndpoint()
        
        // When
        guard webLoader.startLoading() else {
            XCTFail("Should be able to start loading")
            return
        }
        
        await webLoader.request(endpoint) { raw in
            return "Transformed: \(raw)"
        }
        
        // Then
        switch webLoader.state {
        case .success(let content):
            XCTAssertEqual(content, transformedContent)
        default:
            XCTFail("Expected success state, got \(webLoader.state)")
        }
    }
    
    func testAsyncRequestWithCompletion() async {
        // Given
        let expectedContent = "Test Content"
        mockClient.mockResult = .success(expectedContent)
        let endpoint = MockEndpoint()
        var completionCalled = false
        var receivedResult: Result<String, Error>?
        
        // When
        guard webLoader.startLoading() else {
            XCTFail("Should be able to start loading")
            return
        }
        
        await webLoader.request(endpoint) { result in
            completionCalled = true
            receivedResult = result
        }
        
        // Then
        XCTAssertTrue(completionCalled)
        switch receivedResult {
        case .success(let content):
            XCTAssertEqual(content, expectedContent)
        case .failure:
            XCTFail("Expected success result")
        case .none:
            XCTFail("Expected result to be set")
        }
    }
    
    func testAsyncRequestWithoutStartLoading() async {
        // Given
        let endpoint = MockEndpoint()
        
        // When
        await webLoader.request(endpoint)
        
        // Then
        // The request method should still work even without startLoading
        // but it will call finishLoading which changes the state
        switch webLoader.state {
        case .success(let content):
            XCTAssertEqual(content, "Mock Content")
        default:
            XCTFail("Expected success state, got \(webLoader.state)")
        }
    }
    
    func testAsyncLoadMethod() async {
        // Given
        let expectedContent = "Test Content"
        mockClient.mockResult = .success(expectedContent)
        let endpoint = MockEndpoint()
        
        // Create a custom loader that has a custom load method
        let customLoader = CustomWebLoader(apiClient: mockClient, endpoint: endpoint)
        
        // When
        await customLoader.customLoad()
        
        // Then
        switch customLoader.state {
        case .success(let content):
            XCTAssertEqual(content, expectedContent)
        default:
            XCTFail("Expected success state, got \(customLoader.state)")
        }
    }
    
}


@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
private final class CustomWebLoader: WebLoader<String> {
    private let testEndpoint: MockEndpoint
    
    init(apiClient: Client, endpoint: MockEndpoint) {
        self.testEndpoint = endpoint
        super.init(apiClient: apiClient)
    }
    
    func customLoad() async {
        guard startLoading() else { return }
        await request(testEndpoint)
    }
}
