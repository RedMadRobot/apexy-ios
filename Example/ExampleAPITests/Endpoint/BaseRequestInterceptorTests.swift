//
//  BaseRequestInterceptorTests.swift
//  ExampleAPITests
//
//  Created by Anton Glezman on 12.03.2021.
//  Copyright © 2021 RedMadRobot. All rights reserved.
//

import Apexy
import Alamofire
import ExampleAPI
import XCTest

final class BaseRequestInterceptorTests: XCTestCase {
    
    let baseURL = URL(string: "https://example.com/api")!
    var adapter: Alamofire.RequestInterceptor {
        BaseRequestInterceptor(baseURL: baseURL)
    }
    
    func testAdapt_PathWithTrailingSlash() {
        let request = URLRequest(url: URL(string: "path/")!)
        let exp = expectation(description: "Adapting url request")
        adapter.adapt(request, for: .default) { result in
            let request = try! result.get()
            assertURL(request, "https://example.com/api/path/")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func testAdapt_PathWithoutTrailingSlash() {
        let request = URLRequest(url: URL(string: "path")!)
        let exp = expectation(description: "Adapting url request")
        adapter.adapt(request, for: .default) { result in
            let request = try! result.get()
            assertURL(request, "https://example.com/api/path")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}
