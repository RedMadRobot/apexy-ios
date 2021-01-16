//
//  JsonEndpoint.swift
//
//  Created by Alexander Ignatev on 08/02/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import Apexy

/// Base Endpoint for application remote resource.
///
/// Contains shared logic for all endpoints in app.
protocol JsonEndpoint: Endpoint, URLRequestBuildable where Content: Decodable {}

extension JsonEndpoint {

    public typealias Failure = Error
    
    /// Request body encoder.
    internal var encoder: JSONEncoder { return JSONEncoder.default }

    public func decode(
        fromResponse response: URLResponse?,
        withResult result: Result<Data, Error>) -> Result<Content, Failure> {
        return result.flatMap { body -> Result<Content, Error> in
            do {
                try ResponseValidator.validate(response, with: body)
                let resource = try JSONDecoder.default.decode(ResponseData<Content>.self, from: body)
                return .success(resource.data)
            } catch {
                return .failure(error)
            }
        }
    }
}

// MARK: - Response

private struct ResponseData<Resource>: Decodable where Resource: Decodable {
    let data: Resource
}
