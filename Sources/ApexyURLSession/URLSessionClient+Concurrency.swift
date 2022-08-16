//
//  File.swift
//  
//
//  Created by Aleksei Tiurnin on 15.08.2022.
//

import Apexy
import Foundation

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
extension URLSessionClient: ConcurrencyClient {
        
    open func request<T>(_ endpoint: T) async throws -> T.Content where T : Endpoint {
        var request = try endpoint.makeRequest()
        request = try requestAdapter.adapt(request)
        var response: (data: Data, response: URLResponse)?
        var error: Error?
        
        defer {
            completionQueue.async { [request, response, error] in
                self.responseObserver?(request, response?.response as? HTTPURLResponse, response?.data, error)
            }
        }
        
        do {
            response = try await session.data(for: request)
            
            if let httpResponse = response?.response as? HTTPURLResponse {
                try endpoint.validate(request, response: httpResponse, data: response?.data)
            }
            
            let data = response?.data ?? Data()
            return try endpoint.content(from: response?.response, with: data)
        } catch let someError {
            error = someError
            throw someError
        }
    }
    
    open func upload<T>(_ endpoint: T) async throws -> T.Content where T : UploadEndpoint {
        var request: (request: URLRequest, body: UploadEndpointBody) = try endpoint.makeRequest()
        request.request = try requestAdapter.adapt(request.request)
        var response: (data: Data, response: URLResponse)?
        var error: Error?
        
        defer {
            completionQueue.async { [request, response, error] in
                self.responseObserver?(request.request, response?.response as? HTTPURLResponse, response?.data, error)
            }
        }
        
        do {
            switch request {
            case (_, .data(let data)):
                response = try await session.upload(for: request.request, from: data)
            case (_, .file(let url)):
                response = try await session.upload(for: request.request, fromFile: url)
            case (_, .stream):
                throw URLSessionClientError.uploadStreamUnimplemented
            }
            
            let data = response?.data ?? Data()
            return try endpoint.content(from: response?.response, with: data)
        } catch let someError {
            error = someError
            throw someError
        }
    }

}
