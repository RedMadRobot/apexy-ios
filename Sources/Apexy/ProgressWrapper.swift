//
//  ProgressWrapper.swift
//  ApexyURLSession
//
//  Created by Aleksei Tiurnin on 20.01.2022.
//

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
    
    private var _progress: Progress?
    private let lock = NSLock()
    
    public init(_progress: Progress? = nil) {
        self._progress = _progress
    }
    
    public func cancel() {
        progress?.cancel()
    }
}
