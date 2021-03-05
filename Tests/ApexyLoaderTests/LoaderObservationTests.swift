@testable import ApexyLoader
import XCTest

final class LoaderObservationTests: XCTestCase {

    private var observation: LoaderObservation!

    func testDeinit() {
        // Given
        var numberOfTriggers = 0
        observation = LoaderObservation {
            numberOfTriggers += 1
        }

        // When
        observation = nil

        // Then
        XCTAssertEqual(numberOfTriggers, 1, "Обработчик вызвался один раз")
    }
}
