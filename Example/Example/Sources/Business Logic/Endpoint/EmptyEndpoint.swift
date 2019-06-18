//
//  EmptyEndpoint.swift
//
//  Created by Alexander Ignatev on 18/02/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import ApiClient

/// Эндпойт для запросов с ответом без тела.
protocol EmptyEndpoint: Endpoint where Content == Void {}

extension EmptyEndpoint {

    public func content(from response: URLResponse?, with body: Data) throws {
        try ResponseValidator.validate(response, with: body)
    }
}
