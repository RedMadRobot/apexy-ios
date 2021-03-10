@testable import ApexyLoader
import XCTest

final class ContentLoaderTests: XCTestCase {

    private var contentLoader: ContentLoader<Int>!
    private var numberOfChanges = 0
    private var observation: LoaderObservation!

    override func setUp() {
        super.setUp()
        
        numberOfChanges = 0
        contentLoader = ContentLoader<Int>()
        observation = contentLoader.observe { [weak self] in
            self?.numberOfChanges += 1
        }

        XCTAssertTrue(
            contentLoader.observations.isEmpty,
            "No observation of other loaders")
        XCTAssertEqual(
            contentLoader.state,
            .initial,
            "Initial loader state")
    }

    func testCancelObservation() {
        observation = nil
        contentLoader.state = .success(content: 10)
        XCTAssertEqual(
            numberOfChanges, 0,
            "The change handler didn‘t triggered because the observation was canceled")
    }

    func testStartLoading() {
        XCTAssertTrue(
            contentLoader.startLoading(),
            "Loading has begun")
        XCTAssertTrue(
            contentLoader.state == .loading(cache: nil),
            "State of the loader must be loading")
        XCTAssertEqual(
            numberOfChanges, 1,
            "Change handler triggered")

        XCTAssertFalse(
            contentLoader.startLoading(),
            "The second loading didn‘t start before the end of the first one.")
        XCTAssertTrue(
            contentLoader.state == .loading(cache: nil),
            "The load status has NOT changed")
        XCTAssertEqual(
            numberOfChanges, 1,
            "The change handler did NOT triggered")
    }

    func testFinishLoading() {
        contentLoader.finishLoading(.success(12))
        XCTAssertTrue(
            contentLoader.state == .success(content: 12),
            "Succesfull loading state")
        XCTAssertEqual(
            numberOfChanges, 1,
            "The change handler triggered")

        let error = URLError(.networkConnectionLost)
        contentLoader.finishLoading(.failure(error))
        XCTAssertTrue(
            contentLoader.state == .failure(error: error, cache: 12),
            "The state must me failure with cache")
        XCTAssertEqual(
            numberOfChanges, 2,
            "The handler triggered")
    }

    func testUpdate() {
        contentLoader.update(.initial)
        XCTAssertEqual(
            numberOfChanges, 0,
            "The state didn't change and the handler didn't triggered")

        contentLoader.update(.success(content: 1))
        XCTAssertEqual(
            numberOfChanges, 1,
            "The state changed and the handler triggered")

        contentLoader.update(.success(content: 1))
        XCTAssertEqual(
            numberOfChanges, 1,
            "The state didn't changed and the handler didn't triggered")
    }
}
