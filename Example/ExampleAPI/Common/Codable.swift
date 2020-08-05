//
//  Codable.swift
//
//  Created by Alexander Ignatev on 18/02/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import Foundation

extension JSONEncoder {
    internal static let `default`: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()
}

extension JSONDecoder {
    internal static let `default`: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}
