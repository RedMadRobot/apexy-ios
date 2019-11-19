//
//  APIError.swift
//
//  Created by Alexander Ignatev on 08/02/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import Foundation

/// Error from API.
public struct APIError: Decodable, Error {

    /// Код ошибки.
    public struct Code: RawRepresentable, Decodable, Equatable {
        public var rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
    }

    /// Error code.
    public let code: Code

    /// Error description.
    public let description: String?

    public init(
        code: Code,
        description: String? = nil) {

        self.code = code
        self.description = description
    }
}

// MARK: - General Error Code

extension APIError.Code {
    
    /// Invalid Token Error.
    public static let tokenInvalid = APIError.Code("token_invalid")
    
}
