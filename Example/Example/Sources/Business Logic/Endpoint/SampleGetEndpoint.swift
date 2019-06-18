//
//  SampleGetEndpoint.swift
//
//  Created by Anton Glezman on 17/06/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import ApiClient

/// Пример GET запроса
public struct SampleGetEndpoint: GetEndpoint {
    
    public typealias Content = GetResponse
    
    public let query: String
    
    var url: URL {
        return URL(string: "get")!
    }
    
    var queryParameters: [String: String]? {
        return ["query": query]
    }
    
    init(query: String) {
        self.query = query
    }
}
