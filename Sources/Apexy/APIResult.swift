//
//  APIResult.swift
//  
//
//  Created by Aleksei Tiurnin on 17.08.2022.
//

import Foundation

public typealias APIResult<Value> = Swift.Result<Value, Error>

public extension APIResult {
    var error: Error? {
        switch self {
        case .failure(let error):
            return error
        default:
            return nil
        }
    }
}
