//
//  ServiceLayer.swift
//  Example
//
//  Created by Anton Glezman on 18/06/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import ApiClient

final class ServiceLayer {
    
    static let shared = ServiceLayer()
    
    private(set) lazy var apiClient: Client = {
        return ApiClient.Client(
            baseURL: URL(string: "https://postman-echo.com/")!,
            configuration: .ephemeral)
    }()
    
    private(set) lazy var sampleService: SampleService = {
        return SampleServiceImpl(apiClient: apiClient)
    }()
    
}
