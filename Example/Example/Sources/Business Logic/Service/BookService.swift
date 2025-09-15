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
    func fetchBooks() async throws -> [Book]
}


final class BookServiceImpl: BookService {
    
    let apiClient: Client
    
    init(apiClient: Client) {
        self.apiClient = apiClient
    }
    
    func fetchBooks() async throws -> [Book] {
        let endpoint = BookListEndpoint()
        return try await apiClient.request(endpoint)
    }
}
