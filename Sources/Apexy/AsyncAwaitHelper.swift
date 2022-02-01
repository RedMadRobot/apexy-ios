//
//  AsyncAwaitHelper.swift
//  
//
//  Created by Aleksei Tiurnin on 31.01.2022.
//

import Foundation

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public enum AsyncAwaitHelper {
    public typealias ContentContinuation<T> = CheckedContinuation<T, Error>

    public static func adaptToAsync<T>(dataTaskClosure: (ContentContinuation<T>) -> Progress) async throws -> T {
        let progressWrapper = ProgressWrapper()
        return try await withTaskCancellationHandler(handler: {
            progressWrapper.cancel()
        }, operation: {
            try await withCheckedThrowingContinuation { (continuation: ContentContinuation<T>) in
                let progress = dataTaskClosure(continuation)
                progressWrapper.progress = progress
            }
        })
    }
}
