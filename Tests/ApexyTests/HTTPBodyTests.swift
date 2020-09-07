//
//  HTTPBodyTests.swift
//
//  Created by Daniil Subbotin on 07.09.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

import Apexy
import XCTest

final class HTTPBodyTests: XCTestCase {
    
    func testJsonHttpBody() {
        let emptyData = Data()
        
        let json = HTTPBody.json(emptyData)
        
        XCTAssertEqual(json.data, emptyData)
        XCTAssertEqual(json.contentType, "application/json")
    }
    
    func testFormHttpBody() {
        let emptyData = Data()
        
        let json = HTTPBody.form(emptyData)
        
        XCTAssertEqual(json.data, emptyData)
        XCTAssertEqual(json.contentType, "application/x-www-form-urlencoded")
    }
    
    func testBinaryHttpBody() {
        let emptyData = Data()
        
        let json = HTTPBody.binary(emptyData)
        
        XCTAssertEqual(json.data, emptyData)
        XCTAssertEqual(json.contentType, "application/octet-stream")
    }
    
    func testStringHttpBody() {
        let json = HTTPBody.string("Test")
        
        let testData = "Test".data(using: .utf8)
        XCTAssertEqual(json.data, testData)
        XCTAssertEqual(json.contentType, "text/plain")
    }
    
    func testTextHttpBody() {
        let testData = "Test".data(using: .utf8)!
        
        let json = HTTPBody.text(testData)
        
        XCTAssertEqual(json.data, testData)
        XCTAssertEqual(json.contentType, "text/plain")
    }
}
