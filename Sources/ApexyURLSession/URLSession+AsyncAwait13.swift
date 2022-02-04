//
//  URLSession+AsyncAwait13.swift
//  ApexyURLSession
//
//  Created by Aleksei Tiurnin on 20.01.2022.
//

import Apexy
import Foundation

@available(macOS, introduced: 10.15, deprecated: 12, message: "Extension is no longer necessary. Use API built into SDK")
@available(iOS, introduced: 13, deprecated: 15, message: "Extension is no longer necessary. Use API built into SDK")
@available(watchOS, introduced: 6, deprecated: 8, message: "Extension is no longer necessary. Use API built into SDK")
@available(tvOS, introduced: 13, deprecated: 15, message: "Extension is no longer necessary. Use API built into SDK")
extension URLSession {
    
    public func data(
        for request: URLRequest,
        delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse) {
            return try await AsyncAwaitHelper.adaptToAsync(dataTaskClosure: { continuation in
                let task = dataTask(with: request) { data, response, error in
                    guard let data = data, let response = response else {
                        let error = error ?? URLError(.badServerResponse)
                        return continuation.resume(throwing: error)
                    }
                    continuation.resume(returning: (data, response))
                }
                task.resume()
                return task.progress
            })
        }
    
    public func upload(
        for request: URLRequest,
        fromFile fileURL: URL,
        delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse) {
            return try await AsyncAwaitHelper.adaptToAsync(dataTaskClosure: { continuation in
                let task = uploadTask(with: request, fromFile: fileURL) { data, response, error in
                    guard let data = data, let response = response else {
                        let error = error ?? URLError(.badServerResponse)
                        return continuation.resume(throwing: error)
                    }
                    continuation.resume(returning: (data, response))
                }
                task.resume()
                return task.progress
            })
        }

    public func upload(
        for request: URLRequest,
        from bodyData: Data,
        delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse) {
            return try await AsyncAwaitHelper.adaptToAsync(dataTaskClosure: { continuation in
                let task = uploadTask(with: request, from: bodyData) { data, response, error in
                    guard let data = data, let response = response else {
                        let error = error ?? URLError(.badServerResponse)
                        return continuation.resume(throwing: error)
                    }
                    continuation.resume(returning: (data, response))
                }
                task.resume()
                return task.progress
            })
        }
}
