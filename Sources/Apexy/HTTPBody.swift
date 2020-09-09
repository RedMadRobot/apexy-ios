//
//  HTTPBody.swift
//
//  Created by z.samarskaya on 30/06/2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

import Foundation

/// The HTTP body for request
public struct HTTPBody {
    public let data: Data
    public let contentType: String
    
    public init(data: Data, contentType: String) {
        self.data = data
        self.contentType = contentType
    }
}

public extension HTTPBody {
    /// Create HTTP body with json content type.
    ///
    /// - Parameters:
    ///   - data: HTTP body data.
    /// - Returns: HTTPBody.
    static func json(_ data: Data) -> HTTPBody {
        return HTTPBody(data: data, contentType: "application/json")
    }

    /// Create HTTP body with form-urlencoded content type.
    ///
    /// - Parameters:
    ///   - data: HTTP body data.
    /// - Returns: HTTPBody.
    static func form(_ data: Data) -> HTTPBody {
        return HTTPBody(data: data, contentType: "application/x-www-form-urlencoded")
    }

    /// Create HTTP body with text/plain content type.
    ///
    /// - Parameters:
    ///   - data: HTTP body data.
    /// - Returns: HTTPBody.
    static func text(_ data: Data) -> HTTPBody {
        return HTTPBody(data: data, contentType: "text/plain")
    }

    /// Create HTTP body with text/plain content type.
    ///
    /// - Parameters:
    ///   - data: HTTP body data.
    /// - Returns: HTTPBody.
    static func string(_ string: String) -> HTTPBody {
        return HTTPBody(data: Data(string.utf8), contentType: "text/plain")
    }

    /// Create HTTP body with octet-stream content type.
    ///
    /// - Parameters:
    ///   - data: HTTP body data.
    /// - Returns: HTTPBody.
    static func binary(_ data: Data) -> HTTPBody {
        return HTTPBody(data: data, contentType: "application/octet-stream")
    }
}
