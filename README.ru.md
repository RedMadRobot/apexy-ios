# API Client

Библиотека для организации сетевого слоя в проекте.

- Не зависит от реализации работы с сетью. Может быть использована `URLSession` или `Alamofire`.
- Выделяйте объекты для работы с сетью в отдельный модуль, таргет или библиотеку, чтобы они находились изолировано в своём `namespace`.
- Разбивайте запросы на отдельные структуры. Классы не запрещаются, но делайте их неизменяемыми. `enum` могут подойти, если разные запросы имеют одинаковый ответ на них.

## Endpoint

`Endpoint` - один из базовых протоколов организации работы с REST API. Является совокупностью запроса и обработки ответа.

> Обязательно не мутабельный.

1. Создает `URLRequest` для отправки запроса.
2. Валидирует ответ на наличие ошибок API.
3. Преобразует ответ в нужный тип (`Data`, `String`, `Decodable`).

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

`APIClient` - объект с одним методом способный выполнить `Endpoint`.
- Легко мокается, так как у него один метод.
- Легко отправить через него несколько разных `Endpoint`.
- Легко оборачивается в декораторы или адаптеры. Например можно обернуть в `RxSwift` или `Combine` и вам не придется делать обертки для каждого запроса.

Разделение на `APIClient` и `Endpoint` позволяет разделить асинхронынй код в `APIClient` от синхронного кода в `Endpoint`. Таким образом сайд эффекты изолированы в одном месте `APIClient`, а чистые функции в немутабельных `Endpoint`.

## Getting Started

Так как большинство запросов будут получать JSON, то на уровне модуля нужно сделать базовые протоколы. Они будут содержать в себе общую логику запросов для конкретной API.

`JsonEndpoint` - базовый протокол для запросов ожидающих JSON в теле ответа.

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

`VoidEndpoint` базовый протокол для запросов не ожидающих тела ответа.
```swift
public protocol VoidEndpoint: Endpoint where Content == Void {}

extension VoidEndpoint {
    public func validate(_ response: URLResponse?, with body: Data) throws {
        // TODO: check API / HTTP error
    }

    public func content(from response: URLResponse?, with body: Data) throws {}
}
```

`BookListEndpoint` - получения списка книг.
```swift
public struct BookListEndpoint: JsonEndpoint, URLRequestBuildable {
    public typealias Content = [Book]

    public func makeRequest() throws -> URLRequest {
        return get(URL(string: "books")!)
    }
}
```

`BookEndpoint` - получения книги по `ID`.
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

`UpdateBookEndpoint` - обновление книги.

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

> Для удобства конструирования `URLRequest` вы можете использовать функции из `HTTP`.

`DeleteBookEndpoint` - удаление книги по `ID`.

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

### Отправка данных на сервер

Для отправки файлов или больших объемов данных вы можете использовать `UploadEndpoint`. В методе `makeRequest()` необходимо вернуть `URLRequest` и загружаемые данные, это может быть файл `.file(URL)`, данные `.data(Data)` или поток `.stream(InputStream)`. Для выполнения запроса вызовите метод `Client.upload(endpoint:, completionHandler:)`. С помощью объекта `Progress` вы сможете отслеживать прогресс загрузки данных либо отменить запрос.

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

## Организация сетевого слоя

Если приложение называется `Household`, то модуль с сетью будет называться `HouseholdAPI`.

Разбивайте сетевой слой на папки:
- `Model` папка с модельками сетевого уровня. То что отправляем и то что получаем в ответах.
- `Endpoint` папка с запросами.
- `Common` общие хелперы. Например `APIError`.

### Итоговая структура файлов и папок.

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

## Дополнительные материалы

- [Вложенные ответы](nested_response.ru.md)
- [Тестирование]
- [Обработка ошибок](error_handling.ru.md)
- [Реактивное программирование](reactive.ru.md)
