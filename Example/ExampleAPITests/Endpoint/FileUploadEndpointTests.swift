//
//  FileUploadEndpointTests.swift
//  ExampleAPITests
//
//  Created by Daniil Subbotin on 28.07.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

import ExampleAPI
import XCTest

final class FileUploadEndpointTests: XCTestCase {

    func testMakeRequest() throws {
        let fileURL = URL(string: "path/to/file")!
        let endpoint = FileUploadEndpoint(fileURL: fileURL)
        
        let (request, body) = try! endpoint.makeRequest().get()
        
        assertPOST(request)
        assertURL(request, "upload")
        assertHTTPHeaders(request, [
            "Content-Type": "application/octet-stream"
        ])
        
        switch body {
        case .file(let url):
            XCTAssertEqual(url, fileURL)
        default:
            XCTFail("urlRequest's UploadEndpointBody must be .file")
        }
    }

}
