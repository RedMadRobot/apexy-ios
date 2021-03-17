@testable import ApexyLoader
import XCTest

final class LoaderObservationTests: XCTestCase {

    private var observation: LoaderObservation!

    func testDeinit() {
        var numberOfTriggers = 0
        observation = LoaderObservation {
            numberOfTriggers += 1
        }

        observation = nil

        XCTAssertEqual(numberOfTriggers, 1, "The handler triggered once")
    }
}
