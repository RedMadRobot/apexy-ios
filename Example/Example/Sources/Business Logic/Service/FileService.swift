//
//  FileService.swift
//  DemoApp
//
//  Created by Anton Glezman on 17/06/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import Apexy
import ExampleAPI

protocol FileService {
    func upload(file: URL) async throws
    func upload(stream: InputStream, size: Int) async throws
}


final class FileServiceImpl: FileService {
    
    let apiClient: ConcurrencyClient
    
    init(apiClient: ConcurrencyClient) {
        self.apiClient = apiClient
    }
        
    func upload(file: URL) async throws {
        let endpoint = FileUploadEndpoint(fileURL: file)
        return try await apiClient.upload(endpoint)
    }
    
    func upload(stream: InputStream, size: Int) async throws {
        let endpoint = StreamUploadEndpoint(stream: stream, size: size)
        return try await apiClient.upload(endpoint)
    }
    
}
