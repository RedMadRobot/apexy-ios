//
//  URLSessionClientTests.swift
//
//  Created by Daniil Subbotin on 07.09.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

import Apexy
import Apexy_URLSession
import XCTest

final class URLSessionClientTests: XCTestCase {
    
    private var client: URLSessionClient!
    
    override func setUp() {
        let url = URL(string: "https://booklibrary.com")!
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        
        client = URLSessionClient(baseURL: url, configuration: config)
    }
    
    func testClientRequest() {
        let endpoint = EmptyEndpoint()
        let data = "Test".data(using: .utf8)!
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "2.0", headerFields: nil)!
            return (response, data)
        }
        
        let exp = expectation(description: "wait for response")
        _ = client.request(endpoint) { result in
            switch result {
            case .success(let content):
                XCTAssertEqual(content, data)
            case .failure:
                XCTFail("Expected result: .success, actual result: .failure")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    func testClientUpload() {
        let data = "apple".data(using: .utf8)!
        let endpoint = SimpleUploadEndpoint(data: data)
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "2.0", headerFields: nil)!
            return (response, data)
        }
        
        let exp = expectation(description: "wait for response")
        _ = client.upload(endpoint, completionHandler: { result in
            switch result {
            case .success(let content):
                XCTAssertEqual(content, data)
            case .failure:
                XCTFail("Expected result: .success, actual result: .failure")
            }
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1)
    }
    
    @available(iOS 13.0, *)
    @available(OSX 10.15, *)
    func testClientRequestUsingCombine() throws {
        let endpoint = EmptyEndpoint()
        let data = "Test".data(using: .utf8)!
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "2.0", headerFields: nil)!
            return (response, data)
        }
        
        let exp = expectation(description: "wait for response")
        
        let publisher = client.request(endpoint)
        _ = publisher.sink(receiveCompletion: { result in
            switch result {
            case .finished:
                break
            case .failure:
                XCTFail("Expected result: .finished, actual result: .failure")
            }
            exp.fulfill()
        }) { content in
            XCTAssertEqual(content, data)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.1)
    }
}

private final class MockURLProtocol: URLProtocol {
    
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data) )?
    
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func stopLoading() {}
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else { return }
        do {
            let (response, data)  = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch  {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
}

private struct EmptyEndpoint: Endpoint {
    
    typealias Content = Data
    
    func makeRequest() throws -> URLRequest {
        URLRequest(url: URL(string: "empty")!)
    }
    
    func content(from response: URLResponse?, with body: Data) throws -> Data {
        return body
    }
}

private struct SimpleUploadEndpoint: UploadEndpoint {
   
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

