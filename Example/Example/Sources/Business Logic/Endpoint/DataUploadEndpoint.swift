//
//  DataUploadEndpoint.swift
//  Example
//
//  Created by Anton Glezman on 17.06.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

import ApiClient

public struct DataUploadEndpoint: UploadEndpoint {
    
    public typealias Content = Void
    
    public var dataToUpload: Uploadable {
        let data = Data(count: 100_000_000)
        return .data(data)
    }
    
    public func content(from response: URLResponse?, with body: Data) throws {
        try ResponseValidator.validate(response, with: body)
    }
    
    public func makeRequest() throws -> URLRequest {
        var request = URLRequest(url: URL(string: "post")!)
        request.httpMethod = "POST"
        return request
    }
}
