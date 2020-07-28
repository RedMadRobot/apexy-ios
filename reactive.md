# Reactive programming

## APIClient extension for integrating with RxSwift

If you want to use APIClient with RxSwift copy the following extension to your project.

```swift
extension Client {
    
    func request<T>(_ endpoint: T) -> Single<T.Content> where T: Endpoint {
        Single.create { single in
            let progress = self.request(endpoint) { (result: Result<T.Content, Error>) in
                switch result {
                case .success(let content):
                    single(.success(content))
                case .failure(let error):
                    single(.error(error))
                }
            }
            return Disposables.create(with: progress.cancel)
        }
    }
    
}
```

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

If you want to use APIClient with Combine copy the following extension to your project.

```swift
extension Client {
    
    func request<T>(_ endpoint: T) -> AnyPublisher<T.Content, Error> where T: Endpoint {
        let subject = PassthroughSubject<T.Content, Error>()
        
        let progress = self.request(endpoint) { (result: Result<T.Content, Error>) in
                switch result {
                case .success(let content):
                    subject.send(content)
                    subject.send(completion: .finished)
                case .failure(let error):
                    subject.send(completion: .failure(error))
            }
        }
        
        return subject.handleEvents(receiveCancel: {
            progress.cancel()
            subject.send(completion: .finished)
        }).eraseToAnyPublisher()
    }
}
```

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
