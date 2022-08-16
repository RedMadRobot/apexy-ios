import Foundation

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
}
