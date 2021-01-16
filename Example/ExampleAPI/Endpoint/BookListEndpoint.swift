//
//  BookListEndpoint.swift
//
//  Created by Anton Glezman on 17/06/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import Apexy

/// Example of GET request.
public struct BookListEndpoint: JsonEndpoint {
    
    public typealias Content = [Book]

    
    public init() {}
    
    public func makeRequest() -> Result<URLRequest, Error> {
        return .success(get(URL(string: "books")!))
    }
}
