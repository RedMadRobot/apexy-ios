//
//  StreamUploadEndpoint.swift
//  ExampleAPI
//
//  Created by Anton Glezman on 18.06.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

import Apexy

/// Endpoint for uploading a data form a stream
public struct StreamUploadEndpoint: UploadEndpoint {
    
    public typealias Content = Void
    public typealias Failure = Error
    
    private let stream: InputStream
    private let size: Int
    
    public init(stream: InputStream, size: Int) {
        self.stream = stream
        self.size = size
    }
    
    public func makeRequest() -> Result<(URLRequest, UploadEndpointBody), Error> {
        var request = URLRequest(url: URL(string: "upload")!)
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        
        // To track upload progress, it is important to set the Content-Length value.
        request.setValue("\(size)", forHTTPHeaderField: "Content-Length")
        return .success((request, .stream(stream)))
    }
    
    public func decode(fromResponse response: URLResponse?, withResult result: Result<Data, Error>) -> Result<Void, Error> {
        return result.flatMap { body -> Result<Void, Error> in
            do {
                return .success(try ResponseValidator.validate(response, with: body))
            } catch {
                return .failure(error)
            }
        }
    }
}
