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
    
    @discardableResult
    func upload(file: URL, completion: @escaping (Result<Void, Error>) -> Void) -> Progress
    
    @discardableResult
    func upload(stream: InputStream, size: Int, completion: @escaping (Result<Void, Error>) -> Void) -> Progress
    
   @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    func upload(file: URL) async throws
    
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    func upload(stream: InputStream, size: Int) async throws
}


final class FileServiceImpl: FileService {
    
    let apiClient: Client
    
    init(apiClient: Client) {
        self.apiClient = apiClient
    }
    
    func upload(file: URL, completion: @escaping (Result<Void, Error>) -> Void) -> Progress {
        let endpoint = FileUploadEndpoint(fileURL: file)
        return apiClient.upload(endpoint, completionHandler: completion)
    }
    
    func upload(stream: InputStream, size: Int, completion: @escaping (Result<Void, Error>) -> Void) -> Progress {
        let endpoint = StreamUploadEndpoint(stream: stream, size: size)
        return apiClient.upload(endpoint, completionHandler: completion)
    }
    
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    func upload(file: URL) async throws {
        let endpoint = FileUploadEndpoint(fileURL: file)
        return try await apiClient.upload(endpoint)
    }
    
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    func upload(stream: InputStream, size: Int) async throws {
        let endpoint = StreamUploadEndpoint(stream: stream, size: size)
        return try await apiClient.upload(endpoint)
    }
    
}
