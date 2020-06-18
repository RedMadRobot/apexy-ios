//
//  GetEndpoint.swift
//
//  Created by Aleksandr Khlebnikov on 05/03/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import Foundation

/// Protocol for GET request.
protocol GetEndpoint: BaseEndpoint {
    
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
        
        var components = URLComponents(
            url: url,
            resolvingAgainstBaseURL: true)!
        
        let queryItems: [URLQueryItem]? = queryParameters?.map({ URLQueryItem(name: $0.key, value: $0.value) })
        components.queryItems = queryItems
        
        let request = URLRequest(url: components.url!)

        return request
    }
    
}
