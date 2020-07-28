//
//  FileUploadEndpoint.swift
//  ExampleAPI
//
//  Created by Anton Glezman on 17.06.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

import ApiClient

/// Endpoint for uploading a file
public struct FileUploadEndpoint: UploadEndpoint {
    
    public typealias Content = Void
    
    private let fileURL: URL
    
    public init(fileURL: URL) {
        self.fileURL = fileURL
    }
    
    public func content(from response: URLResponse?, with body: Data) throws {
        try ResponseValidator.validate(response, with: body)
    }
    
    public func makeRequest() throws -> (URLRequest, UploadEndpointBody) {
        var request = URLRequest(url: URL(string: "upload")!)
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        return (request, .file(fileURL))
    }
}
