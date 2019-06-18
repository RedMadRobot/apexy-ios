//
//  APIError.swift
//
//  Created by Alexander Ignatev on 08/02/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import Foundation

/// Ошибка API.
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

    /// Код ошибки.
    public let code: Code

    /// Описание ошибки.
    public let description: String?

    
    public init(
        code: Code,
        description: String? = nil) {

        self.code = code
        self.description = description
    }
}
