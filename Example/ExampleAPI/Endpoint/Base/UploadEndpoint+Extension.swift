//
//  UploadEndpoint.swift
//  ExampleAPI
//
//  Created by Aleksei Tiurnin on 15.01.2021.
//  Copyright © 2021 RedMadRobot. All rights reserved.
//

import Apexy

extension UploadEndpoint {

    public typealias ErrorType = Error
    
    public func error(from response: URLResponse?, with body: Data?, and error: Error) -> Error {
        return error
    }
}
