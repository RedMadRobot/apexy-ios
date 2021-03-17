/// Represents content loading state.
public enum LoadingState<Content> {

    /// Initial empty state.
    case initial

    /// Content is loading.
    ///
    /// - `cache`: Cached content that was previously loaded.
    case loading(cache: Content?)

    /// Content successfull loaded.
    ///
    /// - `content`: Actual loaded content.
    case success(content: Content)

    /// Content failed to load.
    ///
    /// - `error`: An error that occurs while loading content.
    /// - `cache`: Cached content that was previously loaded.
    case failure(error: Error, cache: Content?)
}

// MARK: - Properties

extension LoadingState {
    
    public var content: Content? {
        switch self {
        case .loading(let content?),
             .success(let content),
             .failure(_, let content?):
            return content
        default:
            return nil
        }
    }

    public var isLoading: Bool {
        switch self {
        case .loading:
            return true
        default:
            return false
        }
    }

    public var error: Error? {
        switch self {
        case .failure(let error, _):
            return error
        default:
            return nil
        }
    }
}

// MARK: - Methods

public extension LoadingState {

    /// Merges two states.
    func merge<C2, C3>(_ state: LoadingState<C2>, transform: (Content, C2) -> C3) -> LoadingState<C3> {
        
        switch (self, state) {
        case (.loading(let cache1?), _):
            let cache3 = state.content.map { transform(cache1, $0) }
            return LoadingState<C3>.loading(cache: cache3)
        case (_, .loading(let cache2?)):
            let cache3 = content.map { transform($0, cache2) }
            return LoadingState<C3>.loading(cache: cache3)
        case (.loading, _),
             (_, .loading):
            return LoadingState<C3>.loading(cache: nil)
        case (.failure(let error, let cache1?), _):
            let cache3 = state.content.map { transform(cache1, $0) }
            return LoadingState<C3>.failure(error: error, cache: cache3)
        case (_, .failure(let error, let cache2?)):
            let cache3 = content.map { transform($0, cache2) }
            return LoadingState<C3>.failure(error: error, cache: cache3)
        case (.failure(let error, _), _),
             (_, .failure(let error, _)):
            return LoadingState<C3>.failure(error: error, cache: nil)
        case (.success(let lhs), .success(let rhs)):
            return LoadingState<C3>.success(content: transform(lhs, rhs))
        case (.initial, .initial),
             (.initial, .success),
             (.success, .initial):
            return LoadingState<C3>.initial
        }
    }
}

// MARK: - Equatable

extension LoadingState: Equatable where Content: Equatable {
    static public func == (lhs: LoadingState<Content>, rhs: LoadingState<Content>) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial):
            return true
        case (.failure(_, let cache1), .failure(_, let cache2)),
             (.loading(let cache1), .loading(let cache2)):
            return cache1 == cache2
        case (.success(let content1), .success(let content2)):
            return content1 == content2
        default:
            return false
        }
    }
}

// MARK: - CustomStringConvertible

extension LoadingState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .initial:
            return "Initial"
        case .loading(let cache):
            return "Loading: cache \(String(describing: cache))"
        case .success(let content):
            return "Success: \(content)"
        case .failure(let error, let cache):
            return "Failure: \(error), cache \(String(describing: cache))"
        }
    }
}
