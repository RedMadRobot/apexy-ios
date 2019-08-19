//
//  ServiceLayer.swift
//  Example
//
//  Created by Anton Glezman on 18/06/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import ApiClient

final class ServiceLayer {
    
    // MARK: - Public properties
    
    static let shared = ServiceLayer()
    
    private(set) lazy var apiClient: Client = {
        return ApiClient.Client(
            baseURL: URL(string: "https://postman-echo.com/")!,
            configuration: .ephemeral,
            responseObserver: { [weak self] request, response, data, error in
                self?.validateSession(responseError: error)
            })
    }()
    
    private(set) lazy var sampleService: SampleService = {
        return SampleServiceImpl(apiClient: apiClient)
    }()
    
    
    // MARK: - Private methods
    
    private func validateSession(responseError: Error?) {
        if let error = responseError as? APIError, error.code == .tokenInvalid {
            // TODO: Logout
        }
    }
}
