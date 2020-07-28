//
//  FormUploadEndpointTests.swift
//  ExampleAPITests
//
//  Created by Daniil Subbotin on 28.07.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

import ExampleAPI
import XCTest
import Alamofire

final class FormUploadEndpointTests: XCTestCase {

    func testMakeRequest() throws {
        let endpoint = FormUploadEndpoint(form: Form(fields: []))
        let urlRequest = try endpoint.makeRequest()
        
        let request = urlRequest.0
        
        assertPOST(request)
        assertURL(request, "form")
        
        XCTAssertNil(request.httpBody)
    }

}
