# Вложенные ответы

Почти всегда сервер возвращает json объекты вложенные в другие объекты.  

Рассмотрим пару запросов и два случая, когда сервер может может возвращать ответ вложенным.

Запросы:
- `GET books/` Получение списка книг. Ожидаем массив книг `Book`.
- `GET books/{book_id}` Получение книги по `id` Ожидаем просто книгу `Book`.

```swift
public struct Book: Codable, Identifiable {
    public let id: Int
    public let name: String
}
```

## Вложенные ответы с одинаковым ключом

В первом случае сервер будет оборачивать объекты ответов в `data`.

```json
{
  "data": "content"
}
```

`GET books/`

На запрос получения всех книг вернется массив обернутый в `data`.

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

На запрос получения книги по `id` вернется одна книга обернутая в `data`.

```json
{
  "data": {
    "id": "A-1",
    "name": "Mu mu",    
  }
}
```

Чтобы скрыть обертку `data`, создадим `JsonEndpoint`, который будет доставать необходимый нам `Content`.

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

В итоге наши запросы скрывают вложенность ответа.

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

## Вложенные ответы с разными ключами

Во втором более сложном случае сервер будет отправлять ответы вложенные в разные ключи.

`GET books/`

На запрос получения всех книг вернется массив обернутый в `book_list`.

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

На запрос получения книги по `id` вернется одна книга обернутая в `book`.

```json
{
  "book": {
    "id": "A-1",
    "name": "Mu mu",    
  }
}
```

Для разворачивания ответов создадим `JsonEndpoint` c методом `content(from:)`, который будет разворачивать ответы.

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

Таким образом запрос получения всех книг будет оформлен так.

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

> Обратите внимание, что `BookList` и `content(from:)` остались `internal` и скрывают особенности формата ответа.

Для получения книги по `id` запрос будет таким.

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

# Заключение

В конце я бы отметил, что эти два случая могут комбинироваться, и это позволит вам работать без бойлерплейта со сложными API.
