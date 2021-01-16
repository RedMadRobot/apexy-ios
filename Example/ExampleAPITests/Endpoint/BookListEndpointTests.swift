//
//  BookListEndpointTests.swift
//  ExampleAPITests
//
//  Created by Daniil Subbotin on 28.07.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

import ExampleAPI
import XCTest

final class BookListEndpointTests: XCTestCase {

    func testMakeRequest() throws {
        let endpoint = BookListEndpoint()
        let urlRequest = endpoint.makeRequest()
        
        let request = try! urlRequest.get()
        
        assertGET(request)
        assertURL(request, "books")
    }

}
