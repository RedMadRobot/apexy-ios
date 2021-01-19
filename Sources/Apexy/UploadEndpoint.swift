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
    associatedtype Failure: Error

    /// Create a new `URLRequest`.
    ///
    /// - Returns: Resource request.
    func makeRequest() -> Result<(URLRequest, UploadEndpointBody), Failure>

    /// Obtain content from response with result
    ///
    /// - Parameters:
    ///   - response: The metadata associated with the response.
    ///   - result: Result which contain Data or Error
    /// - Returns: A new endpoint content.
    func decode(
        fromResponse response: URLResponse?,
        withResult result: Result<Data, Error>) -> Result<Content, Failure>
}
