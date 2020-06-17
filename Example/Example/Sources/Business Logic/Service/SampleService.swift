//
//  SampleService.swift
//  DemoApp
//
//  Created by Anton Glezman on 17/06/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import ApiClient

protocol SampleService {
    
    @discardableResult
    func obtainData(query: String, completion: @escaping (Result<GetResponse, Error>) -> Void) -> Progress
    
    @discardableResult
    func uploadData(completion: @escaping (Result<Void, Error>) -> Void) -> Progress
}


final class SampleServiceImpl: SampleService {
    
    let apiClient: Client
    
    init(apiClient: Client) {
        self.apiClient = apiClient
    }
    
    func obtainData(query: String, completion: @escaping (Result<GetResponse, Error>) -> Void) -> Progress {
        let endpoint = SampleGetEndpoint(query: query)
        return apiClient.request(endpoint, completionHandler: completion)
    }
    
    func uploadData(completion: @escaping (Result<Void, Error>) -> Void) -> Progress {
        let endpoint = DataUploadEndpoint()
        return apiClient.request(endpoint, completionHandler: completion)
    }
}
