# Реактивное программирование

## Расширение Apexy для работы с RxSwift

Если вы хотите использовать Apexy с RxSwift добавьте `Apexy/RxSwift` в Podfile.

`pod 'Apexy/RxSwift'`

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

## Combine

Apexy поддерживает Combine.

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
