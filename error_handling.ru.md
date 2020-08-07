# Обработка ошибок

## Типы ошибок

Есть несколько типов ошибок:
* Ошибки API — например, когда неправильно введен логин или пароль.
* Ошибки сети (URLError) — например, когда интернет не доступен (URLError.notConnectedToInternet)
* HTTP ошибки (HTTPURLResponse) — например, если страница не найдена то statusCode у HTTPURLResponse будет равен 404.
* Ошибки парсинга (DecodingError) — например если при декодинге есть несоответствие типов. В модельном объекте `var id: String`, а с сервера пришло `"id": 123`

## Подготовка к обработке ошибок

Обработка API и HTTP ошибок должна происходить перед попыткой декодировать ответ от сервера в методе `func content(from response: URLResponse?, with body: Data) throws -> Content` протокола `Endpoint`. Ниже показан пример базового протокола `BaseEndpoint` которому будут соответствовать все остальные `Endpoint`. В `BaseEndpoint` происходит валидация и декодирование ответа от сервера.

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

`BaseEndpoint` протокол имеет `associatedtype Root: Decodable` что позволяет указывать декодируемый тип в объектах `Endpoint` соответствующих `BaseEndpoint`. Пример:
```swift
public struct BookListEndpoint: BaseEndpoint {
    public typealias Content = [Book]
    ...
}
```

В `BaseEndpoint` считается что ответ от сервера всегда будет приходить в поле data.
```json
{
    "data": { декодируемый объект }
}
```

## Обработка ошибок декодинга (DecodingError)

В примере выше ошибка декодинга может произойти в методе `public func content(from response: URLResponse?, with body: Data) throws -> Content {`. Она будет передана в completionHandler при вызове метода `request` у экземпляра `Client`.

## Обработка сетевых ошибок (URLError)

Если возникнет сетевая ошибка, то она будет передана в completionHandler при вызове метода `request` у экземпляра `Client`.

## Обработка ошибкок API

Обычно в спецификации API есть описание формата ошибок. Пример:
```json
{
    "error": {
        "code": "token_invalid",
        "title": "Токен неверный"
    }
}
```

В коде модельный объект описывающий эту ошибку выглядит так:

```swift
struct ResponseError: Decodable {
    let error: APIError
}

struct APIError: Decodable, Error {
    let code: String
    let title: String
}
```

Чтобы проверить ответ от сервера на наличие API ошибки создайте `ResponseValidator` как показано в примере ниже.

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

В примере выше при вызове метода `validate` происходит попытка декодировать ответ в виде ошибки. Если в процессе декодирования произошла ошибка — значит ответ от сервера не является ошибкой.

## Обработка HTTP ошибок

HTTP ошибка имеет статус код, URL и описание. Создадим стуктуру описывающую HTTP ошибку.

```swift
public struct HTTPError: Error {
    public let statusCode: Int
    public let url: URL?

    public var localizedDescription: String {
        return HTTPURLResponse.localizedString(forStatusCode: statusCode)
    }
}
```

Добавим метод для валидации HTTP ошибок в `ResponseValidator`.
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
Если статус код не будет лежать в диапазоне 200..<300 то метод validate кинет ошибку HTTPError.
