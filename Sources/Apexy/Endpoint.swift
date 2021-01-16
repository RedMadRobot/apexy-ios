//
//  Endpoint.swift
//
//  Created by Alexander Ignatev on 08/02/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import Foundation

/// The endpoint to work with a remote content.
public protocol Endpoint {

    /// Resource type.
    ///
    /// - Author: Nino
    associatedtype Content
    
    /// Error type
    associatedtype Failure: Error

    /// Create a new `URLRequest`.
    ///
    /// - Returns: Resource request.
    func makeRequest() -> Result<URLRequest, Failure>

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
