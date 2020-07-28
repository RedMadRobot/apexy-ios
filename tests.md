# Testing ApiClient

## What to test?
You can test all the Endpoints and models which contains business logic.

### Endpoint
In the case of Endpoint, test how it creates the URLRequest object (method `makeRequest`):
* HTTP method
* URL address
* HTTP Body
* HTTP headers

**Example**

There is a `BookListEndpoint` in the example project. This endpoint is used to obtain a list of books. The following example shows how to test this Endpoint.

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
This test checks that:
* HTTP method equals to "GET"
* HTTP body doesn't exist
* url equals to "books"

### Model
If a model object contains business logic, then this object must be tested. For example, if a model object has computed properties where data is formatted.

You can also test decoding of a model object in the case of complex transformations, for example, converting a string to a date.

```swift
/// An abstract access code that has an expiration date
struct Code: Decodable, Equatable {
    /// Code value, e.g. "1234"
    let code: String
    /// Code expiration date
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

## Helpers
The following helpers can be used to improve readability and reduce the amount of code in tests:

_Asserts.swift_
```swift
func assertGET(_ urlRequest: URLRequest, file: StaticString = #file, line: UInt = #line) {
    guard let method = urlRequest.httpMethod else {
        return XCTFail("The request does not contains HTTP method", file: file, line: line)
    }
    XCTAssertEqual(method, "GET", file: file, line: line)
    XCTAssertNil(urlRequest.httpBody, "GET request must not contains body", file: file, line: line)
}

func assertPOST(_ urlRequest: URLRequest, file: StaticString = #file, line: UInt = #line) {
    guard let method = urlRequest.httpMethod else {
        return XCTFail("The request does not contains HTTP method", file: file, line: line)
    }
    XCTAssertEqual(method, "POST", file: file, line: line)
}

func assertDELETE(_ urlRequest: URLRequest, file: StaticString = #file, line: UInt = #line) {
    guard let method = urlRequest.httpMethod else {
        return XCTFail("The request does not contains HTTP method", file: file, line: line)
    }
    XCTAssertEqual(method, "DELETE", file: file, line: line)
}

func assertPATCH(_ urlRequest: URLRequest, file: StaticString = #file, line: UInt = #line) {
    guard let method = urlRequest.httpMethod else {
        return XCTFail("The request does not contains HTTP method", file: file, line: line)
    }
    XCTAssertEqual(method, "PATCH", file: file, line: line)
}

func assertPath(_ urlRequest: URLRequest, _ path: String, file: StaticString = #file, line: UInt = #line) {
    guard let url = urlRequest.url else {
        return XCTFail("The request does not contains HTTP method", file: file, line: line)
    }
    XCTAssertEqual(url.path, path, "Paths does not equal", file: file, line: line)
}

func assertURL(_ urlRequest: URLRequest, _ urlString: String, file: StaticString = #file, line: UInt = #line) {
    guard let url = urlRequest.url else {
        return XCTFail("The request does not contains HTTP method", file: file, line: line)
    }
    XCTAssertEqual(url.absoluteString, urlString, "URLs does not equal", file: file, line: line)
}
```

The example above could be written like this:
```swift
func testMakeRequest() throws {
    let endpoint = BookListEndpoint()
    let urlRequest = try endpoint.makeRequest()
    
    assertGET(urlRequest)
    assertURL(urlRequest, "books")
}
```