//
//  FormUploadEndpoint.swift
//  Example
//
//  Created by Anton Glezman on 19.06.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

import ApiClient
import Alamofire

/// Endpoint for sending data with `multipart/form-data` format
public struct FormUploadEndpoint: UploadEndpoint {
    
    public typealias Content = Void
    
    public var dataToUpload: Uploadable {
        return .data(data)
    }
    
    private let data: Data
    private let contentType: String
    private let contentLength: UInt64
    
    /// When creating the `FormUploadEndpoint` object, Form is encoded into the `multipart/form-data` format,
    /// with a large amount of data, this process may take some time;
    /// it is recommended to perform it on the private queue.
    init(form: Form) throws {
        let multipartFormData = MultipartFormData.make(with: form)
        data = try multipartFormData.encode()
        contentLength = multipartFormData.contentLength
        contentType = multipartFormData.contentType
    }
    
    public func content(from response: URLResponse?, with body: Data) throws {
        try ResponseValidator.validate(response, with: body)
    }
    
    public func makeRequest() throws -> URLRequest {
        var request = URLRequest(url: URL(string: "form")!)
        request.httpMethod = "POST"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue("\(contentLength)", forHTTPHeaderField: "Content-Length")
        return request
    }
}


private extension MultipartFormData {
    
    static func make(with form: Form) -> MultipartFormData {
        let multipart = MultipartFormData()
        
        for field in form.fields {
            switch (field.fileName, field.mimeType) {
            case (.some(let fileName), .some(let mime)):
                multipart.append(field.data, withName: field.name, fileName: fileName, mimeType: mime)
            case (.some(let fileName), .none):
                multipart.append(field.data, withName: field.name, fileName: fileName, mimeType: "application/octet-stream")
            case (.none, .some(let mime)):
                multipart.append(field.data, withName: field.name, mimeType: mime)
            case (.none, .none):
                multipart.append(field.data, withName: field.name)
            }
        }
        
        return multipart
    }
}
