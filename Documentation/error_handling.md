# Error handling

## The types of errors

There are several types of errors:
* API Errors — e.g. when the username or password is wrong.
* Network errors (URLError) — e.g. when the internet isn't available (URLError.notConnectedToInternet).
* HTTP errors (HTTPURLResponse) — e.g. if a resource isn't found HTTPURLResponse's statusCode will be 404.
* Decoding errors (DecodingError) — e.g. if there's a type mismatch during decoding.

## Preparing for error handling

API and HTTP error handling should take place before trying to decode a response from a server in the method `func content(from response: URLResponse?, with body: Data) throws -> Content` of `Endpoint` protocol. Below you can see an example of the basic `BaseEndpoint` protocol to which all other `Endpoint` will conforms. In `BaseEndpoint` the response from the server is validated and decoded.

**BaseEndpoint.swift**
```swift
import Foundation

protocol BaseEndpoint: Endpoint where Content: Decodable {
    associatedtype Root: Decodable = Content

    func content(from root: Root) -> Content
}

extension BaseEndpoint where Root == Content {
    func content(from root: Root) -> Content { return root }
}

extension BaseEndpoint {

    var encoder: JSONEncoder { return JSONEncoder.default }

    public func content(from response: URLResponse?, with body: Data) throws -> Content {
        try ResponseValidator.validate(response, with: body)
        let resource = try JSONDecoder.default.decode(ResponseData<Root>.self, from: body)
        return content(from: resource.data)
    }
}

// MARK: - Response

struct ResponseData<Resource>: Decodable where Resource: Decodable {
    let data: Resource
}
```

`BaseEndpoint` protocol has `associatedtype Root: Decodable` which allows you to specify the decodable type in `Endpoint` objects that conforms to the `BaseEndpoint` protocol. Example:
```swift
public struct BookListEndpoint: BaseEndpoint {
    public typealias Content = [Book]
    ...
}
```

In `BaseEndpoint` it is assumed that the response from the server will always come to the data field.
```json
{
    "data": { decodable object }
}
```

## Handling decoding errors (DecodingError)

In the example above, a decoding error can occurs in the method `public func content(from response: URLResponse?, with body: Data) throws -> Content {`. The error will be passed to `completionHandler` when calling the `request` method of `Client` instance.

## Handling network errors (URLError)

If a network error occurs it will be passed to `completionHandler` when calling the `request` method from an instance of `Client`.

## Handling API errors

Usually, an API specification contains a description of the error format. Here is an example:
```json
{
    "error": {
        "code": "token_invalid",
        "title": "Token invalid"
    }
}
```

A model object describing this error looks like this:

```swift
struct ResponseError: Decodable {
    let error: APIError
}

struct APIError: Decodable, Error {
    let code: String
    let title: String
}
```

To check the response from the server for an API error, create `ResponseValidator` as shown in the example below.

```swift
enum ResponseValidator {

    static func validate(_ response: URLResponse?, with body: Data) throws {
        try validateAPIResponse(response, with: body)
    }

    private static func validateAPIResponse(_ response: URLResponse?, with body: Data) throws {
        let decoder = JSONDecoder.default
        guard var error = try? decoder.decode(ResponseError.self, from: body).error else {
            return
        }
        throw error
    }
}
```

In the example above, when calling the `validate` method, an attempt is made to decode the response as an error. If there is a decoding error, then the response from the server is not an error.

## Handling HTTP Errors

HTTP error has a status code, URL, and description. Let's create a structure describing an HTTP error.

```swift
public struct HTTPError: Error {
    public let statusCode: Int
    public let url: URL?

    public var localizedDescription: String {
        return HTTPURLResponse.localizedString(forStatusCode: statusCode)
    }
}
```

Let's add a method to validate HTTP errors in `ResponseValidator.validate()`.

```swift
    ...
    static func validate(_ response: URLResponse?, with body: Data) throws {
        try validateAPIResponse(response, with: body)
        try validateHTTPstatus(response)
    }
    ...
    private static func validateHTTPstatus(_ response: URLResponse?) throws {
        guard let httpResponse = response as? HTTPURLResponse,
            !(200..<300).contains(httpResponse.statusCode) else { return }

        throw HTTPError(statusCode: httpResponse.statusCode, url: httpResponse.url)
    }
```

If a status code doesn't belong to the 200...<300 range, the validate method will throw an HTTPError.
