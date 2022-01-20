//
//  BooksService.swift
//  Example
//
//  Created by Anton Glezman on 18.06.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

import Apexy
import ExampleAPI

typealias Book = ExampleAPI.Book

protocol BookService {
    
    @discardableResult
    func fetchBooks(completion: @escaping (Result<[Book], Error>) -> Void) -> Progress
    
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    func fetchBooks() async throws -> [Book]
}


final class BookServiceImpl: BookService {
    
    let apiClient: Client
    
    init(apiClient: Client) {
        self.apiClient = apiClient
    }
    
    func fetchBooks(completion: @escaping (Result<[Book], Error>) -> Void) -> Progress {
        let endpoint = BookListEndpoint()
        return apiClient.request(endpoint, completionHandler: completion)
    }
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func fetchBooks() async throws -> [Book] {
        let endpoint = BookListEndpoint()
        return try await apiClient.request(endpoint)
    }
}
