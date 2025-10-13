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
    
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func testClientRequest() async throws {
        let endpoint = EmptyEndpoint()
        let data = "Test".data(using: .utf8)!
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "2.0", headerFields: nil)!
            return (response, data)
        }
        
        do {
            let content = try await client.request(endpoint)
            XCTAssertEqual(content, data)
        } catch {
            XCTFail("Expected result: .success, actual result: .failure")
        }
    }
    
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func testClientUpload() async throws {
        let data = "apple".data(using: .utf8)!
        let endpoint = SimpleUploadEndpoint(data: data)
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "2.0", headerFields: nil)!
            return (response, data)
        }
        
        do {
            let content = try await client.upload(endpoint)
            XCTAssertEqual(content, data)
        } catch {
            XCTFail("Expected result: .success, actual result: .failure")
        }
    }
}

