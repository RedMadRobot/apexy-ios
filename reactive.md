# Reactive programming

## APIClient extension for integrating with RxSwift

If you want to use APIClient with RxSwift add `ApiClient/RxSwift` pod to your `Podfile`.

`pod 'ApiClient/RxSwift'`

How to use by example `BookService` (see Example project).

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

## APIClient extension for integrating with Combine

If you want to use APIClient with Combine add `ApiClient/Combine` pod to your `Podfile`.

`pod 'ApiClient/Combine'`

How to use by example `BookService` (see Example project).

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
