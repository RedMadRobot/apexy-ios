import Foundation

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public protocol Client: AnyObject {
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
