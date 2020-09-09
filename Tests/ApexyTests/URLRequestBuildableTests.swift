//
//  URLRequestBuildableTests.swift
//
//  Created by Daniil Subbotin on 07.09.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

import Apexy
import XCTest

private struct URLRequestBuilder: URLRequestBuildable {}

final class URLRequestBuildableTests: XCTestCase {

    private let url = URL(string: "https://apple.com")!
    
    func testGet() {
        let queryItems: [URLQueryItem] = [ URLQueryItem(name: "name", value: "John") ]
        
        let urlRequest = URLRequestBuilder().get(url, queryItems: queryItems)
        
        XCTAssertEqual(urlRequest.httpMethod, "GET")
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://apple.com?name=John")
        XCTAssertNil(urlRequest.httpBody)
        XCTAssertNil(urlRequest.allHTTPHeaderFields)
    }
    
    func testPost() {
        let bodyData = "Test".data(using: .utf8)!
        let httpBody = HTTPBody(data: bodyData, contentType: "text/plain")
        
        let urlRequest = URLRequestBuilder().post(url, body: httpBody)
        
        XCTAssertEqual(urlRequest.httpMethod, "POST")
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://apple.com")
        XCTAssertEqual(urlRequest.httpBody, bodyData)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, ["Content-Type": "text/plain"])
    }
    
    func testPatch() {
        let bodyData = "Test".data(using: .utf8)!
        let httpBody = HTTPBody(data: bodyData, contentType: "text/plain")
        
        let urlRequest = URLRequestBuilder().patch(url, body: httpBody)
        
        XCTAssertEqual(urlRequest.httpMethod, "PATCH")
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://apple.com")
        XCTAssertEqual(urlRequest.httpBody, bodyData)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, ["Content-Type": "text/plain"])
    }
    
    func testPut() {
        let bodyData = "Test".data(using: .utf8)!
        let httpBody = HTTPBody(data: bodyData, contentType: "text/plain")
        
        let urlRequest = URLRequestBuilder().put(url, body: httpBody)
        
        XCTAssertEqual(urlRequest.httpMethod, "PUT")
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://apple.com")
        XCTAssertEqual(urlRequest.httpBody, bodyData)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, ["Content-Type": "text/plain"])
    }
    
    func testDelete() {
        let urlRequest = URLRequestBuilder().delete(url)
        
        XCTAssertEqual(urlRequest.httpMethod, "DELETE")
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://apple.com")
        XCTAssertNil(urlRequest.httpBody)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, [:])
    }
}
