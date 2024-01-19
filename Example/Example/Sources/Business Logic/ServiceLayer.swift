//
//  ServiceLayer.swift
//  Example
//
//  Created by Anton Glezman on 18/06/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import Apexy
import ExampleAPI

final class ServiceLayer {
    
    // MARK: - Public properties
    
    static let shared = ServiceLayer()
    
    private(set) lazy var apiClient: ConcurrencyClient = AlamofireClient(
        baseURL: URL(string: "https://library.mock-object.redmadserver.com/api/v1/")!,
        configuration: .ephemeral,
        responseObserver: { [weak self] request, response, data, error in
            self?.validateSession(responseError: error)
        })
    
    private(set) lazy var bookService: BookService = BookServiceImpl(apiClient: apiClient)
    
    private(set) lazy var fileService: FileService = FileServiceImpl(apiClient: apiClient)
    
    
    // MARK: - Private methods
    
    private func validateSession(responseError: Error?) {
        if let error = responseError as? APIError, error.code == .tokenInvalid {
            // TODO: Logout
        }
    }
}
