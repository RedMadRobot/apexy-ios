//
//  AlamofireClientTests.swift
//
//  Created by Daniil Subbotin on 07.09.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

import Apexy
import ApexyAlamofire
import XCTest

final class AlamofireClientTests: XCTestCase {
    
    private var client: AlamofireClient!
    
    override func setUp() {
        let url = URL(string: "https://booklibrary.com")!
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        
        client = AlamofireClient(baseURL: url, configuration: config)
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
    typealias Failure = Error
    
    func makeRequest() -> Result<URLRequest, Error> {
        return .success(URLRequest(url: URL(string: "empty")!))
    }
    
    func decode(fromResponse response: URLResponse?, withResult result: Result<Data, Error>) -> Result<Data, Error> {
        return result
    }
}

private struct SimpleUploadEndpoint: UploadEndpoint {

    typealias Content = Data
    typealias Failure = Error
    
    private let data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    func makeRequest() -> Result<(URLRequest, UploadEndpointBody), Error> {
        var req = URLRequest(url: URL(string: "upload")!)
        req.httpMethod = "POST"
        
        let body = UploadEndpointBody.data(data)
        return .success((req, body))
    }
    
    func decode(fromResponse response: URLResponse?, withResult result: Result<Data, Error>) -> Result<Data, Error> {
        return result
    }
}

