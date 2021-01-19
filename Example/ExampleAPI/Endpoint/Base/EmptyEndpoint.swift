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

    public typealias Failure = Error
    
    func decode(fromResponse response: URLResponse?, withResult result: Result<Data, Error>) -> Result<Content, Failure> {
        return result.flatMap { body -> Result<Content, Error> in
            do {
                return .success(try ResponseValidator.validate(response, with: body))
            } catch {
                return .failure(error)
            }
        }
    }
}
