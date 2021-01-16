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
    
    public func error(fromResponse response: URLResponse?, withBody body: Data?, withError error: Error) -> Error {
        return error
    }
}
