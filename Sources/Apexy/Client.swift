import Foundation

public typealias APIResult<Value> = Swift.Result<Value, Error>

public protocol Client: AnyObject {
    
    /// Send request to specified endpoint.
    ///
    /// - Parameters:
    ///   - endpoint: endpoint of remote content.
    ///   - completionHandler: The completion closure to be executed when request is completed.
    /// - Returns: The progress of fetching the response data from the server for the request.
    func request<T>(
        _ endpoint: T,
        completionHandler: @escaping (APIResult<T.Content>) -> Void
    ) -> Progress where T: Endpoint
    
    /// Upload data to specified endpoint.
    ///
    /// - Parameters:
    ///   - endpoint: The remote endpoint and data to upload.
    ///   - completionHandler: The completion closure to be executed when request is completed.
    /// - Returns: The progress of uploading data to the server.
    func upload<T>(
        _ endpoint: T,
        completionHandler: @escaping (APIResult<T.Content>) -> Void
    ) -> Progress where T: UploadEndpoint
    
    /// Send request to specified endpoint.
    /// - Returns: response data from the server for the request.
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    func request<T>(_ endpoint: T) async throws -> T.Content where T: Endpoint
    
    /// Upload data to specified endpoint.
    /// - Returns: response data from the server for the upload.
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    func upload<T>(_ endpoint: T) async throws -> T.Content where T: UploadEndpoint
    
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension Client {
    
    func request<T>(_ endpoint: T) async throws -> T.Content where T: Endpoint {
        return try await AsyncAwaitHelper.adaptToAsync(dataTaskClosure: { continuation in
            return request(endpoint) { result in
                switch result {
                case .success(let content):
                    return continuation.resume(returning: content)
                case .failure(let error):
                    return continuation.resume(throwing: error)
                }
            }
        })
    }
    
    func upload<T>(_ endpoint: T) async throws -> T.Content where T: UploadEndpoint {
        return try await AsyncAwaitHelper.adaptToAsync(dataTaskClosure: { continuation in
            return upload(endpoint) { result in
                switch result {
                case .success(let content):
                    return continuation.resume(returning: content)
                case .failure(let error):
                    return continuation.resume(throwing: error)
                }
            }
        })
    }
}
