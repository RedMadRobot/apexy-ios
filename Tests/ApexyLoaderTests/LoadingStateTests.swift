@testable import ApexyLoader
import XCTest

final class LoadingStateTests: XCTestCase {

    private let error = URLError(.badURL)

    func testContent() {
        XCTAssertNil(LoadingState<Int>.initial.content)
        XCTAssertNil(LoadingState<Int>.loading(cache: nil).content)
        XCTAssertNil(LoadingState<Int>.failure(error: error, cache: nil).content)

        XCTAssertEqual(LoadingState<Int>.loading(cache: 1).content, 1)
        XCTAssertEqual(LoadingState<Int>.success(content: 2).content, 2)
        XCTAssertEqual(LoadingState<Int>.failure(error: error, cache: 3).content, 3)
    }

    func testIsLoading() {
        XCTAssertTrue(
            LoadingState<Int>.loading(cache: nil).isLoading)
        XCTAssertFalse(
            LoadingState<Int>.initial.isLoading)
        XCTAssertFalse(
            LoadingState<Int>.success(content: 0).isLoading)
        XCTAssertFalse(
            LoadingState<Int>.failure(error: error, cache: 6).isLoading)
    }
    
    func testError() throws {
        XCTAssertNil(
            LoadingState<Int>.loading(cache: nil).error)
        XCTAssertNil(
            LoadingState<Int>.initial.error)
        XCTAssertNil(
            LoadingState<Int>.success(content: 0).error)
        
        let error = try XCTUnwrap(LoadingState<Int>.failure(error: self.error, cache: 6).error as? URLError)
        XCTAssertEqual(error, self.error)
    }

    func testMerge() {
        XCTAssertEqual(
            LoadingState<Int>.loading(cache: 2).merge(.success(content: 3), transform: +),
            LoadingState<Int>.loading(cache: 5))
        XCTAssertEqual(
            LoadingState<Int>.success(content: 2).merge(.loading(cache: 3), transform: +),
            LoadingState<Int>.loading(cache: 5))
        XCTAssertEqual(
            LoadingState<Int>.loading(cache: nil).merge(.success(content: 3), transform: +),
            LoadingState<Int>.loading(cache: nil))
        XCTAssertEqual(
            LoadingState<Int>.success(content: 2).merge(.loading(cache: nil), transform: +),
            LoadingState<Int>.loading(cache: nil))

        XCTAssertEqual(
            LoadingState<Int>.failure(error: error, cache: 7).merge(.failure(error: error, cache: 7), transform: +),
            LoadingState<Int>.failure(error: error, cache: 14))
        XCTAssertEqual(
            LoadingState<Int>.failure(error: error, cache: 7).merge(.success(content: 8), transform: +),
            LoadingState<Int>.failure(error: error, cache: 15))
        XCTAssertEqual(
            LoadingState<Int>.success(content: 9).merge(.failure(error: error, cache: 7), transform: +),
            LoadingState<Int>.failure(error: error, cache: 16))
        XCTAssertEqual(
            LoadingState<Int>.success(content: 9).merge(.failure(error: error, cache: nil), transform: +),
            LoadingState<Int>.failure(error: error, cache: nil))

        XCTAssertEqual(
            LoadingState<Int>.success(content: 5).merge(.success(content: 5), transform: +),
            LoadingState<Int>.success(content: 10))
        XCTAssertEqual(
            LoadingState<Int>.initial.merge(.initial, transform: +),
            LoadingState<Int>.initial)
        XCTAssertEqual(
            LoadingState<Int>.initial.merge(.success(content: 1), transform: +),
            LoadingState<Int>.initial)
        XCTAssertEqual(
            LoadingState<Int>.success(content: 2).merge(.initial, transform: +),
            LoadingState<Int>.initial)
    }

    func testInitialEquatable() {
        XCTAssertEqual(
            LoadingState<Int>.initial,
            LoadingState<Int>.initial)
        XCTAssertNotEqual(
            LoadingState<Int>.initial,
            LoadingState<Int>.loading(cache: nil))
        XCTAssertNotEqual(
            LoadingState<Int>.initial,
            LoadingState<Int>.loading(cache: 76))
        XCTAssertNotEqual(
            LoadingState<Int>.initial,
            LoadingState<Int>.success(content: 23))
        XCTAssertNotEqual(
            LoadingState<Int>.initial,
            LoadingState<Int>.failure(error: error, cache: nil))
        XCTAssertNotEqual(
            LoadingState<Int>.initial,
            LoadingState<Int>.failure(error: error, cache: 100))
    }

    func testLoadingEquatable() {
        XCTAssertEqual(
            LoadingState<Int>.loading(cache: 1),
            LoadingState<Int>.loading(cache: 1))
        XCTAssertNotEqual(
            LoadingState<Int>.loading(cache: 2),
            LoadingState<Int>.loading(cache: 3))
        XCTAssertNotEqual(
            LoadingState<Int>.loading(cache: 4),
            LoadingState<Int>.initial)
        XCTAssertNotEqual(
            LoadingState<Int>.loading(cache: 6),
            LoadingState<Int>.success(content: 6))
        XCTAssertNotEqual(
            LoadingState<Int>.loading(cache: 6),
            LoadingState<Int>.success(content: 7))
        XCTAssertNotEqual(
            LoadingState<Int>.loading(cache: 8),
            LoadingState<Int>.failure(error: error, cache: nil))
    }

    func testSuccessEquatable() {
        XCTAssertEqual(
            LoadingState<Int>.success(content: 43),
            LoadingState<Int>.success(content: 43))
        XCTAssertNotEqual(
            LoadingState<Int>.success(content: 43),
            LoadingState<Int>.success(content: 47))
        XCTAssertNotEqual(
            LoadingState<Int>.success(content: 43),
            LoadingState<Int>.initial)
        XCTAssertNotEqual(
            LoadingState<Int>.success(content: 43),
            LoadingState<Int>.loading(cache: nil))
        XCTAssertNotEqual(
            LoadingState<Int>.success(content: 43),
            LoadingState<Int>.failure(error: error, cache: nil))
    }

    func testFailureEquatable() {
        XCTAssertEqual(
            LoadingState<Int>.failure(error: error, cache: 3),
            LoadingState<Int>.failure(error: error, cache: 3))
        XCTAssertNotEqual(
            LoadingState<Int>.failure(error: error, cache: nil),
            LoadingState<Int>.failure(error: error, cache: 3))
        XCTAssertNotEqual(
            LoadingState<Int>.failure(error: error, cache: nil),
            LoadingState<Int>.initial)
        XCTAssertNotEqual(
            LoadingState<Int>.failure(error: error, cache: nil),
            LoadingState<Int>.loading(cache: nil))
        XCTAssertNotEqual(
            LoadingState<Int>.failure(error: error, cache: nil),
            LoadingState<Int>.success(content: 4))
    }

}
