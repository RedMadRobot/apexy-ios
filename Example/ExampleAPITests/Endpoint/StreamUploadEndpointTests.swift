//
//  StreamUploadEndpointTests.swift
//  ExampleAPITests
//
//  Created by Daniil Subbotin on 28.07.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

import ExampleAPI
import XCTest

final class StreamUploadEndpointTests: XCTestCase {

    func testMakeRequest() throws {
        let fileStream = InputStream(data: Data())
        let fileSize = 1024
        let endpoint = StreamUploadEndpoint(stream: fileStream, size: fileSize)
        
        let urlRequest = try endpoint.makeRequest()
        let request = urlRequest.0
        let body = urlRequest.1
        
        assertPOST(request)
        assertURL(request, "upload")
        assertHTTPHeaders(request, [
            "Content-Type": "application/octet-stream",
            "Content-Length": String(fileSize)
        ])
        
        switch body {
        case .stream(let stream):
            XCTAssertEqual(stream, fileStream)
        default:
            XCTFail("urlRequest's UploadEndpointBody must be .stream")
        }
    }

}
