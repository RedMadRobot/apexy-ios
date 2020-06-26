//
//  StreamUploadEndpoint.swift
//  Example
//
//  Created by Anton Glezman on 18.06.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

import ApiClient

/// Endpoint for uploading a data form a stream
public struct StreamUploadEndpoint: UploadEndpoint {
    
    public typealias Content = Void
    
    public var dataToUpload: Uploadable {
        return .stream(stream)
    }
    
    private let stream: InputStream
    private let size: Int
    
    init(stream: InputStream, size: Int) {
        self.stream = stream
        self.size = size
    }
    
    public func content(from response: URLResponse?, with body: Data) throws {
        try ResponseValidator.validate(response, with: body)
    }
    
    public func makeRequest() throws -> URLRequest {
        var request = URLRequest(url: URL(string: "upload")!)
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        
        // To track upload progress, it is important to set the Content-Length value.
        request.setValue("\(size)", forHTTPHeaderField: "Content-Length")
        return request
    }
}
