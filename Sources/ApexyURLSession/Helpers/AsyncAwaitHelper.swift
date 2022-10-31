import Foundation

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
enum AsyncAwaitHelper {
    
    enum AsyncError: Error, Equatable {
        case cancelledBeforeStart
    }
    
    public typealias ContentContinuation<T> = CheckedContinuation<T, Error>

    public static func adaptToAsync<T>(dataTaskClosure: (ContentContinuation<T>) -> Progress) async throws -> T {
        let progressWrapper = ProgressWrapper()
        return try await withTaskCancellationHandler(handler: {
            progressWrapper.cancel()
        }, operation: {
            guard !progressWrapper.isCancelled else { throw AsyncError.cancelledBeforeStart }
            return try await withCheckedThrowingContinuation { (continuation: ContentContinuation<T>) in
                let progress = dataTaskClosure(continuation)
                progressWrapper.progress = progress
            }
        })
    }
}
