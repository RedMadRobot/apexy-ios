import Foundation

@propertyWrapper struct Locked<T> {
    
    var wrappedValue: T {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _value
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _value = newValue
        }
    }
    
    private var _value: T
    private let lock = NSLock()

    init(wrappedValue: T) {
        self._value = wrappedValue
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
final class ProgressWrapper {
    
    @Locked
    var progress: Progress?
    
    init(_progress: Progress? = nil) {
        self.progress = progress
    }
    
    func cancel() {
        progress?.cancel()
    }
}
