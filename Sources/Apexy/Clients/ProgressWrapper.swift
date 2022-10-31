import Foundation

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class ProgressWrapper {

    public var progress: Progress? {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _progress
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _progress = newValue
        }
    }
    
    public var isCancelled: Bool {
        guard let progress = progress else {
            return false
        }
        return progress.isCancelled
    }
    
    private var _progress: Progress?
    private let lock = NSLock()
    
    public init(_progress: Progress? = nil) {
        self._progress = _progress
    }
    
    public func cancel() {
        progress?.cancel()
    }
}
