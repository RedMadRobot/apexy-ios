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
        let urlRequest = try endpoint.makeRequest()
        
        assertGET(urlRequest)
        assertURL(urlRequest, "books")
    }

}
