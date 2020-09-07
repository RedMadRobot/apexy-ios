//
//  URLRequestBuildable.swift
//
//  Created by z.samarskaya on 30/06/2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

import Foundation

public protocol URLRequestBuildable {
    func get(_ url: URL, queryItems: [URLQueryItem]?) -> URLRequest
    func post(_ url: URL, body: HTTPBody?) -> URLRequest
    func patch(_ url: URL, body: HTTPBody) -> URLRequest
    func put(_ url: URL, body: HTTPBody) -> URLRequest
    func delete(_ url: URL) -> URLRequest
}

public extension URLRequestBuildable {
    
    /// Create HTTP GET request.
    ///
    /// - Parameters:
    ///   - url: Request URL.
    ///   - queryItems: Request parameters.
    /// - Returns: HTTP GET Request.
    func get(_ url: URL, queryItems: [URLQueryItem]? = nil) -> URLRequest {
        guard let queryItems = queryItems, !queryItems.isEmpty else {
            return URLRequest(url: url)
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems
        
        guard let queryURL = components?.url else {
            return URLRequest(url: url)
        }

        return URLRequest(url: queryURL)
    }
    
    /// Create HTTP POST request.
    ///
    /// - Parameters:
    ///   - url: Request URL.
    ///   - body: HTTP body.
    /// - Returns: HTTP POST request.
    func post(_ url: URL, body: HTTPBody?) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        if let body = body {
            request.setValue(body.contentType, forHTTPHeaderField: "Content-Type")
            request.httpBody = body.data
        }
        return request
    }
    
    /// Create HTTP PATCH request.
    ///
    /// - Parameters:
    ///   - url: Request URL.
    ///   - body: HTTP body.
    /// - Returns: HTTP PATCH request.
    func patch(_ url: URL, body: HTTPBody) -> URLRequest {
        var request = post(url, body: body)
        request.httpMethod = "PATCH"
        return request
    }

    /// Create HTTP PUT request.
    ///
    /// - Parameters:
    ///   - url: Request URL.
    ///   - body: HTTP body.
    /// - Returns: HTTP PUT request.
    func put(_ url: URL, body: HTTPBody) -> URLRequest {
        var request = post(url, body: body)
        request.httpMethod = "PUT"
        return request
    }

    /// Create HTTP DELETE request.
    ///
    /// - Parameters:
    ///   - url: Request URL.
    /// - Returns: HTTP DELETE request.
    func delete(_ url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        return request
    }
}
