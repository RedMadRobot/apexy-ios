//
//  UploadEndpoint.swift
//
//  Created by Anton Glezman on 17.06.2020.
//

import Foundation

/// Type of uploadable content
public enum UploadEndpointBody {
    case data(Data)
    case file(URL)
    case stream(InputStream)
}

/// The endpoint for upload data to the remote server.
public protocol UploadEndpoint {
    
    /// Response type.
    associatedtype Content
    
    
    /// Error type
    associatedtype ErrorType: Error

    /// Create a new `URLRequest` and uploadable payload.
    ///
    /// - Returns: Resource request and uploadable data
    /// - Throws: Any error creating request.
    func makeRequest() throws -> (URLRequest, UploadEndpointBody)

    /// Obtain new content from response with body.
    ///
    /// - Parameters:
    ///   - response: The metadata associated with the response.
    ///   - body: The response body.
    /// - Returns: A new endpoint content.
    /// - Throws: Any error creating content.
    func content(from response: URLResponse?, with body: Data) throws -> Content
    
    /// Obtain error from response with body.
    ///
    /// - Parameters:
    ///   - response: The metadata associated with the response.
    ///   - body: The response body.
    ///   - error: The response error.
    /// - Returns: A new endpoint error.
    /// - Throws: Any error creating error.
    func error(from response: URLResponse?, with body: Data?, and error: Error) -> ErrorType
}
