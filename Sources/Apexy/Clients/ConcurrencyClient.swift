//
//  ConcurrencyClient.swift
//  
//
//  Created by Aleksei Tiurnin on 16.08.2022.
//

import Foundation

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public protocol ConcurrencyClient: AnyObject {
    /// Send request to specified endpoint.
    /// - Parameters:
    ///    - endpoint: endpoint of remote content.
    /// - Returns: response data from the server for the request.
    func request<T>(_ endpoint: T) async throws -> T.Content where T: Endpoint
    
    /// Upload data to specified endpoint.
    /// - Parameters:
    ///    - endpoint: endpoint of remote content.
    /// - Returns: response data from the server for the upload.
    func upload<T>(_ endpoint: T) async throws -> T.Content where T: UploadEndpoint
    
}

public typealias APIResult<Value> = Swift.Result<Value, Error>

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension Client where Self: ConcurrencyClient {
    
    func request<T>(_ endpoint: T) async throws -> T.Content where T: Endpoint {
        try await AsyncAwaitHelper.adaptToAsync(dataTaskClosure: { continuation in
            request(endpoint, completionHandler: continuation.resume)
        })
    }
    
    func upload<T>(_ endpoint: T) async throws -> T.Content where T: UploadEndpoint {
        try await AsyncAwaitHelper.adaptToAsync(dataTaskClosure: { continuation in
            upload(endpoint, completionHandler: continuation.resume)
        })
    }
}

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
