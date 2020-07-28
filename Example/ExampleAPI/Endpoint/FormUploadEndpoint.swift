//
//  FormUploadEndpoint.swift
//  ExampleAPI
//
//  Created by Anton Glezman on 19.06.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

import ApiClient
import Alamofire

/// Endpoint for sending data with `multipart/form-data` format
public struct FormUploadEndpoint: UploadEndpoint {
    
    public typealias Content = Void
    
    private let form: Form

    init(form: Form) {
        self.form = form
    }
    
    public func content(from response: URLResponse?, with body: Data) throws {
        try ResponseValidator.validate(response, with: body)
    }
    
    public func makeRequest() throws -> (URLRequest, UploadEndpointBody) {
        let multipartFormData = MultipartFormData.make(with: form)
        let data = try multipartFormData.encode()
        
        var request = URLRequest(url: URL(string: "form")!)
        request.httpMethod = "POST"
        request.setValue(multipartFormData.contentType, forHTTPHeaderField: "Content-Type")
        request.setValue("\(multipartFormData.contentLength)", forHTTPHeaderField: "Content-Length")
        return (request, .data(data))
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
