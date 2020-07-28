# Тестирование ApiClient

## Что тестировать
Нужно тестировать все Endpoint'ы и модельные объекты, если в них есть логика.

### Endpoint
В случае Endpoint тестируется то как он создает объект URLRequest (метод `makeRequest`):
* HTTP метод
* URL адрес
* Тело запроса
* HTTP заголовки

**Пример**

В example проекте есть `BookListEndpoint` для получения списка книг. В примере ниже показано как его тестировать.

```swift
import ExampleAPI
import XCTest

final class BookListEndpointTests: XCTestCase {

    func testMakeRequest() throws {
        let endpoint = BookListEndpoint()

        let urlRequest = try endpoint.makeRequest()
        
        XCTAssertEqual(urlRequest.httpMethod, "GET")
        XCTAssertEqual(urlRequest.httpBody, nil)
        XCTAssertEqual(urlRequest.url?.absoluteString, "books")
    }
}
```
В тесте проверяется что:
* HTTP метод равен "GET"
* Тело запроса отсутствует
* url равен "books"

### Model
Если модельный объект содержит логику то на эту логику надо написать тесты. Например, если модельный объект имеет свойства где происходит форматироване данных, то это нужно протестировать.

Ещё можно протестировать декодинг модельного объекта в случае сложных преобразований, например конвертации строки в дату.

```swift
/// Абстрактный код доступа у которого есть дата окончания действия
struct Code: Decodable, Equatable {
    /// Значение кода, например "1234"
    let code: String
    /// Дата окончания действия кода
    let endDate: Date
}

final class CodeTests: XCTestCase {

    func testDecode() throws {
        let json = """
        {
            "code": "1234",
            "end_date": "2019-03-21T13:13:36Z"
        }
        """.data(using: .utf8)!

        let code = try JSONDecoder().decode(Code.self, from: json)

        XCTAssertEqual(
            code.endDate,
            makeDate(year: 2019, month: 3, day: 21, hour: 13, minute: 13, second: 36))
    }

    private func makeDate(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) -> Date {
        return DateComponents(
            calendar: .current,
            timeZone: TimeZone(secondsFromGMT: 0),
            year: year, month: month, day: day,
            hour: hour, minute: minute, second: second).date!
    }
}
```

## Хелперы
Для улучшения читаемости и уменьшениия количества кода в тестах можно использовать следующие хелперы:

_Asserts.swift_
```swift
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
```

Пример выше мог бы быть записан так:
```swift
func testMakeRequest() throws {
    let endpoint = BookListEndpoint()
    let urlRequest = try endpoint.makeRequest()
    
    assertGET(urlRequest)
    assertURL(urlRequest, "books")
}
```