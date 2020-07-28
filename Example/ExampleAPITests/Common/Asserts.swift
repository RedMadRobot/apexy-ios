//
//  Asserts.swift
//  ExampleAPITests
//
//  Created by Daniil Subbotin on 28.07.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

import XCTest

func assertGET(_ urlRequest: URLRequest, file: StaticString = #file, line: UInt = #line) {
    guard let method = urlRequest.httpMethod else {
        return XCTFail("У запроса остутствует HTTP метод", file: file, line: line)
    }
    XCTAssertEqual(method, "GET", file: file, line: line)
    XCTAssertNil(urlRequest.httpBody, "GET запрос не должен иметь тела", file: file, line: line)
}

func assertPOST(_ urlRequest: URLRequest, file: StaticString = #file, line: UInt = #line) {
    guard let method = urlRequest.httpMethod else {
        return XCTFail("У запроса остутствует HTTP метод", file: file, line: line)
    }
    XCTAssertEqual(method, "POST", file: file, line: line)
}

func assertDELETE(_ urlRequest: URLRequest, file: StaticString = #file, line: UInt = #line) {
    guard let method = urlRequest.httpMethod else {
        return XCTFail("У запроса остутствует HTTP метод", file: file, line: line)
    }
    XCTAssertEqual(method, "DELETE", file: file, line: line)
}

func assertPATCH(_ urlRequest: URLRequest, file: StaticString = #file, line: UInt = #line) {
    guard let method = urlRequest.httpMethod else {
        return XCTFail("У запроса остутствует HTTP метод", file: file, line: line)
    }
    XCTAssertEqual(method, "PATCH", file: file, line: line)
}

func assertPath(_ urlRequest: URLRequest, _ path: String, file: StaticString = #file, line: UInt = #line) {
    guard let url = urlRequest.url else {
        return XCTFail("У запроса остутствует URL", file: file, line: line)
    }
    XCTAssertEqual(url.path, path, "путь запроса не совпадает", file: file, line: line)
}

func assertURL(_ urlRequest: URLRequest, _ urlString: String, file: StaticString = #file, line: UInt = #line) {
    guard let url = urlRequest.url else {
        return XCTFail("У запроса остутствует URL", file: file, line: line)
    }
    XCTAssertEqual(url.absoluteString, urlString, "URL запроса не совпадает", file: file, line: line)
}

func assertHTTPHeaders(_ urlRequest: URLRequest, _ headers: [String: String], file: StaticString = #file) {
    XCTAssertEqual(urlRequest.allHTTPHeaderFields, headers)
}

func assertJsonBody(_ urlRequest: URLRequest, _ json: [String: Any], file: StaticString = #file, line: UInt = #line) {
    guard let body = urlRequest.httpBody else {
        return XCTFail("Нет тела запроса", file: file, line: line)
    }

    if let contentType = urlRequest.value(forHTTPHeaderField: "Content-Type") {
        XCTAssertTrue(contentType.contains("application/json"), "Content-Type запрос не json")
    } else {
        XCTFail("Запрос не содержит хедера Content-Type", file: file, line: line)
    }

    do {
        let json1 = try JSONSerialization.jsonObject(with: body)
        guard let dict = json1 as? NSDictionary else {
            return XCTFail("Тело запроса не json словарь", file: file, line: line)
        }
        XCTAssertEqual(dict, json as NSDictionary, file: file, line: line)
    } catch {
        XCTFail("Тело запроса не в json формате \(error)", file: file, line: line)
    }
}
