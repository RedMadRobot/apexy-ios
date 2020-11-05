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

    /// Create a new `URLRequest`.
    ///
    /// - Returns: Resource request.
    /// - Throws: Any error creating request.
    func makeRequest() throws -> URLRequest

    /// Obtain new content from response with body.
    ///
    /// - Parameters:
    ///   - response: The metadata associated with the response.
    ///   - body: The response body.
    /// - Returns: A new endpoint content.
    /// - Throws: Any error creating content.
    func content(from response: URLResponse?, with body: Data) throws -> Content

    /// Validate response.
    ///
    /// - Parameters:
    ///   - request: The metadata associated with the request.
    ///   - response: The metadata associated with the response.
    ///   - data: The response body data.
    /// - Throws: Any response validation error.
    func validate(_ request: URLRequest?, response: HTTPURLResponse, data: Data?) throws
}

public extension Endpoint {
    func validate(_ request: URLRequest?, response: HTTPURLResponse, data: Data?) { }
}
