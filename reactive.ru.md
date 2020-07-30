# Реактивное программирование

## Расширение APIClient для работы с RxSwift

Если вы хотите использовать APIClient с RxSwift добавьте `ApiClient/RxSwift` в Podfile.

`pod 'ApiClient/RxSwift'`

Как использовать на примере `BookService` (смотри Example проект).

```swift
final class BookService {
    ...
    func fetchBooks() -> Single<[Book]> {
        let endpoint = BookListEndpoint()
        return apiClient.request(endpoint)
    }
    ...
}
```

```swift
bookService.fetchBooks()
    .do(onDispose: { [weak self] in
        self?.activityView.isHidden = true
    })
    .subscribe(onSuccess: { [weak self] books in
        self?.activityView.isHidden = true
        self?.show(books: books)
    }, onError: { [weak self] error in
        self?.activityView.isHidden = true
        self?.resultLabel.text = error.localizedDescription
    }).disposed(by: bag)
```

## Расширение APIClient для работы с Combine

Если вы хотите использовать APIClient с Combine добавьте `ApiClient/Combine` в Podfile.

`pod 'ApiClient/Combine'`

Как использовать на примере `BookService` (смотри Example проект).

```swift
final class BookService {
    ...
    func fetchBooks() -> AnyPublisher<[Book], Error> {
        let endpoint = BookListEndpoint()
        return apiClient.request(endpoint)
    }
    ...
}
```

```swift
bookService.fetchBooks().sink(receiveCompletion: { [weak self] completion in
    self?.activityView.isHidden = true
    switch completion {
    case .finished:
        break
    case .failure(let error):
        self?.resultLabel.text = error.localizedDescription
    }
}, receiveValue: { [weak self] books in
    self?.show(books: books)
}).store(in: &bag)
```
