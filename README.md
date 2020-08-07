# API Client

The library for organizing a network layer in a project.

- The library doesn't depend on the implementation of how to work with the network. You can use `URLSession` or `Alamofire`.
- Separate the objects to work with the network in a separate module, target or library, so that they are isolated in their `namespace`.
- Break down requests into separate structures. Classes are not forbidden, but make them non-mutable. Use `enum` if different requests have the same response.

## Endpoint

`Endpoint` - one of the basic protocols for organizing work with REST API. It is a set of request and response processing.

> Must not be mutable.

1. Creates `URLRequest` for sending the request.
2. Validates a server response for API errors.
3. Converts a server response to the right type (`Data`, `String`, `Decodable`).

```swift
public struct Book: Codable, Identifiable {
    public let id: String
    public let name: String
}

public struct BookEndpoint: Endpoint {
    public typealias Content = Book

    public let id: Book.ID

    public init(id: Book.ID) {
        self.id = id
    }

    public func makeRequest() throws -> URLRequest {
        let url = URL(string: "books")!.appendingPathComponent(id)
        return URLRequest(url: url)
    }

    public func validate(_ response: URLResponse?, with body: Data) throws {
        // TODO: check API / HTTP error
    }

    public func content(from response: URLResponse?, with body: Data) throws -> Content {
        return try JSONDecoder().decode(Content.self, from: body)
    }
}

let client = APIClient ...

let endpoint = BookEndpoint(id: "1")
client.request(endpoint) { (result: Result<Book, Error>)
    print(result)
}
```

## APIClient

`APIClient` - an object with only one method for executing `Endpoint`.
- It's easy to mock, because it has only one method.
- It's easy to send several `Endpoint`.
- Easily wraps into decorators or adapters. For example, you can wrap in `RxSwift` or `Combine` and you don't have to make wrappers for each request.

The separation into `APIClient` and `Endpoint` allows you to separate the asynchronous code in `APIClient` from the synchronous code in `Endpoint`. Thus, the side effects are isolated in `APIClient`, and the pure functions in the non-mutable `Endpoint`.

## Getting Started

Since most requests will receive JSON, it is necessary to make basic protocols at the module level. They will contain common requests logic for a specific API.

`JsonEndpoint` - basic protocol for requests waiting for JSON in the response body.

```swift
public protocol JsonEndpoint: Endpoint where Content: Decodable {}

extension JsonEndpoint {
    public func validate(_ response: URLResponse?, with body: Data) throws {
        // TODO: check API / HTTP error
    }

    public func content(from response: URLResponse?, with body: Data) throws -> Content {
        return try JSONDecoder().decode(Content.self, from: body)
    }
}
```

`VoidEndpoint` basic protocol for requests not waiting for a response body.
```swift
public protocol VoidEndpoint: Endpoint where Content == Void {}

extension VoidEndpoint {
    public func validate(_ response: URLResponse?, with body: Data) throws {
        // TODO: check API / HTTP error
    }

    public func content(from response: URLResponse?, with body: Data) throws {}
}
```

`BookListEndpoint` - get a list of books.
```swift
public struct BookListEndpoint: JsonEndpoint, URLRequestBuildable {
    public typealias Content = [Book]

    public func makeRequest() throws -> URLRequest {
        return get(URL(string: "books")!)
    }
}
```

`BookEndpoint` - get a book by `ID`.
```swift
public struct BookEndpoint: JsonEndpoint, URLRequestBuildable {
    public typealias Content = Book

    public let id: Book.ID

    public init(id: Book.ID) {
        self.id = id
    }

    public func makeRequest() throws -> URLRequest {
        let url = URL(string: "books")!.appendingPathComponent(id)
        return get(url)
    }
}
```

`UpdateBookEndpoint` - update a book.

```swift
public struct UpdateBookEndpoint: JsonEndpoint, URLRequestBuildable {
    public typealias Content = Book

    public let Book: Book

    public func makeRequest() throws -> URLRequest {
        let url = URL(string: "books")!.appendingPathComponent(Book.id)
        return put(url, body: .json(try JSONEncoder().encode("Book")))
    }
}
```

> For the convenience of `URLRequest` building you can use functions from `HTTP`.

`DeleteBookEndpoint` - delete a book by `ID`.

```swift
public struct DeleteBookEndpoint: VoidEndpoint, URLRequestBuildable {
    public let id: Book.ID

    public init(id: Book.ID) {
        self.id = id
    }

    public func makeRequest() throws -> URLRequest {
        let url = URL(string: "books")!.appendingPathComponent(id)
        return delete(url)
    }
}
```

### Sending a large amount of data to the server

You can use `UploadEndpoint` to send files or large amounts of data. In the `makeRequest()` method you need to return `URLRequest` and the data you are uploading, it can be a file `.file(URL)`, a data `.data(Data)` or a stream `.stream(InputStream)`. To execute the request, call the `Client.upload(endpoint: completionHandler:)` method. Use `Progress` object to track the progress of the data upload or cancel the request.

```swift
public struct FileUploadEndpoint: UploadEndpoint {
    
    public typealias Content = Void
    
    private let fileUrl: URL
    
    
    init(fileUrl: URL) {
        self.fileUrl = fileUrl
    }
    
    public func content(from response: URLResponse?, with body: Data) throws {
        // ...
    }
    
    public func makeRequest() throws -> (URLRequest, UploadEndpointBody) {
        var request = URLRequest(url: URL(string: "upload")!)
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        return (request, .file(fileUrl))
    }
}
```

## Network Layer Organization

If your application is called `Household`, the network module will be called `HouseholdAPI`.

Split the network layer into folders:
- `Model` a folder with network-level models. That's what we send to the server and what we get in the response.
- `Endpoint` a folder with requests.
- `Common` a folder with common helpers e.g. `APIError`.

### The final file and folder structure

- Household
- HouseholdAPI
  - Model
    - Book
  - Endpoint
    - `JsonEndpoint`
    - `VoidEndpoint`
    - Book
      - `BookListEndpoint`
      - `BookEndpoint`
      - `UpdateBookEndpoint`
      - `DeleteBookEndpoint`
  - Common
    - `APIError`
- HouseholdAPITests
  - Endpoint
    - `Book`
      - `BookListEndpointTests`
      - `BookEndpointTests`
      - `UpdateBookEndpointTests`
      - `DeleteBookEndpointTests`

## Additional resources

- [Nested response](nested_response.md)
- [Testing](tests.md)
- [Error handling]
- [Reactive programming](reactive.md)
