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
            "Нет наблюдений за другими загрузчиками")
        XCTAssertEqual(
            contentLoader.state,
            .initial,
            "Начальное состояние загрузчика")
    }

    func testCancelObservation() {
        observation = nil
        contentLoader.state = .success(content: 10)
        XCTAssertEqual(
            numberOfChanges, 0,
            "Обработчик изменений не сработал, потому что произошла отмена наблюдения")
    }

    func testStartLoading() {
        XCTAssertTrue(
            contentLoader.startLoading(),
            "Началась загрузка")
        XCTAssertTrue(
            contentLoader.state == .loading(cache: nil),
            "Состояние загрузки")
        XCTAssertEqual(
            numberOfChanges, 1,
            "Обработчик изменений сработал")

        XCTAssertFalse(
            contentLoader.startLoading(),
            "Повторная загрузка до окончания первой не отработала")
        XCTAssertTrue(
            contentLoader.state == .loading(cache: nil),
            "Состояние загрузки НЕ поменялось")
        XCTAssertEqual(
            numberOfChanges, 1,
            "Обработчик изменений НЕ сработал")
    }

    func testFinishLoading() {
        contentLoader.finishLoading(.success(12))
        XCTAssertTrue(
            contentLoader.state == .success(content: 12),
            "Состояние успешной загрузки")
        XCTAssertEqual(
            numberOfChanges, 1,
            "Обработчик изменений сработал")

        let error = URLError(.networkConnectionLost)
        contentLoader.finishLoading(.failure(error))
        XCTAssertTrue(
            contentLoader.state == .failure(error: error, cache: 12),
            "Состояние провалившейся загрузки с закешированым результатом")
        XCTAssertEqual(
            numberOfChanges, 2,
            "Обработчик изменений сработал")
    }

    func testUpdate() {
        contentLoader.update(.initial)
        XCTAssertEqual(
            numberOfChanges, 0,
            "Состояние не поменялось и обработчик не сработал")

        contentLoader.update(.success(content: 1))
        XCTAssertEqual(
            numberOfChanges, 1,
            "Новое состояние и обработчик сработал")

        contentLoader.update(.success(content: 1))
        XCTAssertEqual(
            numberOfChanges, 1,
            "Состояние не поменялось и обработчик не сработал")
    }
}
