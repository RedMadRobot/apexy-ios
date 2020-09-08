# Nested Responses

A server almost always returns JSON objects nested in other objects.

Consider a pair of requests and two cases where a server can return nested responses.

Requests:
- `GET books/` Returns a list of books as an array of `Book`.
- `GET books/{book_id}` Returns a `Book` by `id`.

```swift
public struct Book: Codable, Identifiable {
    public let id: Int
    public let name: String
}
```

## Nested responses with the same key

In the first case, a server will wrap the response objects in `data`.

```json
{
  "data": "content"
}
```

`GET books/`

The request to receive all the books will return an array wrapped in `data`.

```json
{
  "data": [
    {
      "id": 1,
      "name": "Mu mu",    
    }
  ]
}
```

`GET books/{book_id}`

The request to recereive a book by `id` will return one book wrapped in `data`

```json
{
  "data": {
    "id": "A-1",
    "name": "Mu mu",    
  }
}
```

To hide the `data` wrapper, let's create `JsonEndpoint`, which will get us the necessary `Content`.

```swift
protocol JsonEndpoint: Endpoint where Content: Decodable {}

extension JsonEndpoint {

    public func content(from response: URLResponse?, with body: Data) throws -> Content {
        let decoder = JSONDecoder()
        let value = try decoder.decode(ResponseData<Content>.self, from: body)
        return value.data
    }
}

private struct ResponseData<Content>: Decodable where Content: Decodable {
    let data: Content
}
```

As a result, our requests hide the nesting of the response.

- `BookListEndpoint.Contnet = [Book]`
- `BookEndpoint.Contnet = Book`

```swift
public struct BookEndpoint: JsonEndpoint {
    public typealias Content = Book
    // ..,
}

public struct BookListEndpoint: JsonEndpoint {
    public typealias Content = [Book]
    // ..,
}
```

## Nested responses with different keys

In the second more complex case, the server will send responses nested with different keys.

`GET books/`

The request to receive all books will return an array wrapped in `book_list`.

```json
{
  "book_list": [
    {
      "id": 1,
      "name": "Mu mu",    
    }
  ]
}
```

`GET books/{book_id}`

The request to receive a book by id will return a book wrapped in `book`.

```json
{
  "book": {
    "id": "A-1",
    "name": "Mu mu",    
  }
}
```

To unwrap responses, create `JsonEndpoint` with the `content(from:)` method which will unwrap the responses.

```swift
protocol JsonEndpoint: Endpoint where Content: Decodable {
    associatedtype Root: Decodable = Content

    func content(from root: Root) -> Content
}

extension JsonEndpoint {

    public func content(from response: URLResponse?, with body: Data) throws -> Content {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let root = try decoder.decode(Root.self, from: body)
        return content(from: root)
    }
}
```

Thus, the request to receive all the books will look like this.

```swift
struct BookListResponse: Decodable {
    let bookList: [Book]
}

public struct BookListEndpoint: JsonEndpoint {
    public typealias Content = [Book]

    func content(from root: BookListResponse) -> Content {
        return root.bookList
    }

    public func makeRequest() throws -> URLRequest {
        return URLRequest(url: URL(string: "books")!)
    }
}
```

> Notice that `BookListResponse` and `content(from:)` remains `internal` and hide the features of the response format.

The request to get a book by `id` will look like this.

```swift
struct BookResponse: Decodable {
    let book: Book
}

public struct BookEndpoint: JsonEndpoint {
    public typealias Content = Book

    public let id: Book.ID

    public init(id: Book.ID) {
        self.id = id
    }

    func content(from root: BookResponse) -> Content {
        return root.book
    }

    public func makeRequest() throws -> URLRequest {
        let url = URL(string: "books")!.appendingPathComponent(id)
        return URLRequest(url: url)
    }
}
```

# Conclusion

In the end, I would note that these two cases can be combined, and it will allow you to work without a boilerplate with complex APIs.