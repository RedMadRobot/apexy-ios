//
//  JsonEndpoint.swift
//
//  Created by Alexander Ignatev on 08/02/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import ApiClient

/// Base Endpoint for application remote resource.
///
/// Contains shared logic for all endpoints in app.
protocol JsonEndpoint: Endpoint, URLRequestBuildable where Content: Decodable {}

extension JsonEndpoint {

    /// Request body encoder.
    internal var encoder: JSONEncoder { return JSONEncoder.default }

    public func content(from response: URLResponse?, with body: Data) throws -> Content {
        try ResponseValidator.validate(response, with: body)
        let resource = try JSONDecoder.default.decode(ResponseData<Content>.self, from: body)
        return resource.data
    }
}

// MARK: - Response

private struct ResponseData<Resource>: Decodable where Resource: Decodable {
    let data: Resource
}
