//
//  FormUploadEndpoint.swift
//  Example
//
//  Created by Anton Glezman on 19.06.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

import ApiClient
import Alamofire

/// Endpoint для отправки данных в формате `multipart/form-data`
public struct FormUploadEndpoint: UploadEndpoint {
    
    public typealias Content = Void
    
    public var dataToUpload: Uploadable {
        return .data(data)
    }
    
    private let data: Data
    private let contentType: String
    private let contentLength: UInt64
    
    /// При создании объекта `FormUploadEndpoint` выполняется кодирование данных в формат `multipart/form-data`,
    /// при большом объеме данных этот процесс может занять некоторое время, лучше выполнять не на главной очереди.
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
