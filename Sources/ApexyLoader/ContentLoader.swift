#if canImport(Combine)
import Combine
#endif
import Foundation

private final class StateChangeHandler {
    let notify: () -> Void

    init(_ notify: @escaping () -> Void) {
        self.notify = notify
    }
}

public protocol ContentLoading: ObservableLoader {
    /// Starts loading data.
    func load()
}

/// A object that stores loaded content, loading state and allow to observing loading state.
open class ContentLoader<Content>: ObservableLoader {

    /// An array of the loader state change handlers
    private var stateHandlers: [StateChangeHandler] = []

    /// An array of the external loader observers.
    final public var observations: [LoaderObservation] = []

    /// Content loading status. The default value is `.initial`.
    ///
    /// - Remark: To change state use `update(_:)`.
    public var state: LoadingState<Content> = .initial {
        didSet {
            stateHandlers.forEach { $0.notify() }
            
            if #available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *) {
                stateSubject.send(state)
            }
        }
    }
    
    // Can not use `@available` with lazy properties on XCode 14. This is a workaround.
    // https://stackoverflow.com/a/55534141/7453375
    private var storedStateSubject: Any? = nil
    @available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
    private var stateSubject: CurrentValueSubject<LoadingState<Content>, Never> {
        if let subject = storedStateSubject as? CurrentValueSubject<LoadingState<Content>, Never> {
            return subject
        }
        let subject = CurrentValueSubject<LoadingState<Content>, Never>(.initial)
        storedStateSubject = subject
        return subject
    }
    
    /// Content loading status. The default value is `.initial`.
    ///
    /// - Remark: To change state use `update(_:)`.
    private var storedStatePublisher: Any? = nil
    @available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
    private var statePublisher: AnyPublisher<LoadingState<Content>, Never>  {
        if let publisher = storedStatePublisher as? AnyPublisher<LoadingState<Content>, Never>  {
            return publisher
        }
        let publisher = stateSubject.eraseToAnyPublisher()
        storedStatePublisher = publisher
        return publisher
    }
    
    public init() {}
    
    // MARK: - ObservableLoader
    
    /// Starts state observing.
    ///
    /// - Parameter changeHandler: A closure to execute when the loader state changes.
    /// - Returns: An instance of the `LoaderObservation`.
    final public func observe(_ changeHandler: @escaping () -> Void) -> LoaderObservation {
        let handler = StateChangeHandler(changeHandler)
        stateHandlers.append(handler)
        return LoaderObservation { [weak self] in
            if let index = self?.stateHandlers.firstIndex(where: { $0 === handler }) {
                self?.stateHandlers.remove(at: index)
            }
        }
    }

    // MARK: - Loading
    
    /// Updates the loader state to `.loading`.
    ///
    /// Call this method before loading data to update the loader state.
    /// - Returns: A boolean value indicating the possibility to start loading data. The method return `false` if the current state is `loading`.
    @discardableResult
    final public func startLoading() -> Bool {
        if state.isLoading {
            return false
        }
        state = .loading(cache: state.content)
        return true
    }
    
    /// Updates the loader state using result.
    ///
    /// Call this method at the end of data loading to update the loader state.
    /// - Parameter result: Data loading result.
    final public func finishLoading(_ result: Result<Content, Error>) {
        switch result {
        case .success(let content):
            state = .success(content: content)
        case .failure(let error):
            state = .failure(error: error, cache: state.content)
        }
    }
}

// MARK: - Content + Equatable

public extension ContentLoader where Content: Equatable {
    
    /// Updates state of the loader.
    /// - Parameter state: New state.
    func update(_ state: LoadingState<Content>) {
        if self.state != state {
            self.state = state
        }
    }
}
