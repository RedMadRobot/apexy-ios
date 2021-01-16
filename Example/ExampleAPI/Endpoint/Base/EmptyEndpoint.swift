//
//  EmptyEndpoint.swift
//
//  Created by Alexander Ignatev on 18/02/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import Apexy

/// Empty Body Request Enpoint.
protocol EmptyEndpoint: Endpoint, URLRequestBuildable where Content == Void {}

extension EmptyEndpoint {

    public typealias ErrorType = Error
    
    public func content(from response: URLResponse?, with body: Data) throws {
        try ResponseValidator.validate(response, with: body)
    }
    
    public func error(fromResponse response: URLResponse?, withBody body: Data?, withError error: Error) -> ErrorType {
        return error
    }
}
