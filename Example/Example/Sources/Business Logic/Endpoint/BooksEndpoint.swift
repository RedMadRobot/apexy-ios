//
//  BookListEndpoint.swift
//
//  Created by Anton Glezman on 17/06/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import ApiClient

/// Example of GET request.
public struct BookListEndpoint: JsonEndpoint {
    
    public typealias Content = [Book]

    public func makeRequest() throws -> URLRequest {
        return URLRequest(url: URL(string: "books")!)
    }

}
