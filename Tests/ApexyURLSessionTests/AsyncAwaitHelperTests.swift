//
//  AsyncAwitHelperTests.swift
//  
//
//  Created by Aleksei Tiurnin on 31.10.2022.
//

import XCTest
@testable import ApexyURLSession

final class AsyncAwaitHelperTests: XCTestCase {

    func testExample() async throws {
        let task = Task<String, Error>(priority: .background) {
            try await AsyncAwaitHelper.adaptToAsync(dataTaskClosure: { continuation in
                continuation.resume(returning: "123")
                return Progress()
            })
        }
        let value = try await task.value
        XCTAssertEqual(value, "123")
    }
    
    func testCancelExample() async throws {
        let task = Task<String, Error>(priority: .background) {
            try await AsyncAwaitHelper.adaptToAsync(dataTaskClosure: { continuation in
                continuation.resume(returning: "123")
                return Progress()
            })
        }
        task.cancel()
        do {
            _ = try await task.value
            XCTAssert(false)
        } catch {
            XCTAssertEqual(error as! AsyncAwaitHelper.AsyncError, AsyncAwaitHelper.AsyncError.cancelledBeforeStart)
        }
    }

}
