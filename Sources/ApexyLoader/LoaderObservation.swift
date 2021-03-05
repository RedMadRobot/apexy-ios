/// Cancels observation for changes to `ContentLoader` on deinitialization.
///
/// - Remark: Works like `NSKeyValueObservation`, `AnyCancellable` and `DisposeBag`.
public final class LoaderObservation {
    typealias Cancel = () -> Void

    private let cancel: Cancel

    init(_ cancel: @escaping Cancel) {
        self.cancel = cancel
    }

    deinit {
        cancel()
    }
}
