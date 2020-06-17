//
//  UploadEndpoint.swift
//  ApiClient
//
//  Created by Anton Glezman on 17.06.2020.
//

import Foundation

public enum Uploadable {
    case data(Data)
    case file(URL)
    case stream(InputStream)
}

/// The endpoint for upload data to the remote server.
public protocol UploadEndpoint: Endpoint {
    
    var dataToUpload: Uploadable { get }
    
}
