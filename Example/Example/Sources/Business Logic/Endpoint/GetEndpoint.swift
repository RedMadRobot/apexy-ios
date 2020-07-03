//
//  GetEndpoint.swift
//
//  Created by Aleksandr Khlebnikov on 05/03/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import ApiClient
import Foundation

/// Protocol for GET request.
protocol GetEndpoint: BaseEndpoint, URLRequestBuildable {
    
    /// url запроса без base url
    var url: URL { get }
    
    /// Параметры запроса
    var queryParameters: [String: String]? { get }
}

extension GetEndpoint {
    
    public var queryParameters: [String: String]? {
        return nil
    }
    
    public func makeRequest() throws -> URLRequest {
        let queryItems = queryParameters?.map({ URLQueryItem(name: $0.key, value: $0.value) })
        return get(url, queryItems: queryItems)
    }
    
}
