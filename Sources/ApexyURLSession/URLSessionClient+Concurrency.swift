//
//  URLSessionClient+Concurrency.swift
//  
//
//  Created by Aleksei Tiurnin on 15.08.2022.
//

import Apexy
import Foundation

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
extension URLSessionClient: ConcurrencyClient {
    
    private func observeResponse(
        info: (request: URLRequest?, data: Data?, response: URLResponse?),
        error: Error) {
            self.responseObserver?(
                info.request,
                info.response as? HTTPURLResponse,
                info.data,
                error)
        }
    
    open func request<T>(_ endpoint: T) async throws -> T.Content where T : Endpoint {
        
        var info: (request: URLRequest?, data: Data?, response: URLResponse?) = (nil, nil, nil)
        
        do {
            var request = try endpoint.makeRequest()
            request = try requestAdapter.adapt(request)
            
            info.request = request
            
            let result: (data: Data, response: URLResponse) = try await session.data(for: request)
            
            info.data = result.data
            info.response = result.response
            
            if let httpResponse = result.response as? HTTPURLResponse {
                try endpoint.validate(request, response: httpResponse, data: result.data)
            }
            
            return try endpoint.content(from: result.response, with: result.data)
        } catch {
            Task.detached { [weak self, info] in
                self?.observeResponse(info: info, error: error)
            }
            throw error
        }
    }
    
    open func upload<T>(_ endpoint: T) async throws -> T.Content where T : UploadEndpoint {
        
        var info: (request: URLRequest?, data: Data?, response: URLResponse?) = (nil, nil, nil)
        
        do {
            var request: (request: URLRequest, body: UploadEndpointBody) = try endpoint.makeRequest()
            request.request = try requestAdapter.adapt(request.request)
            
            info.request = request.request
            
            let result: (data: Data, response: URLResponse)
            switch request {
            case (_, .data(let data)):
                result = try await session.upload(for: request.request, from: data)
            case (_, .file(let url)):
                result = try await session.upload(for: request.request, fromFile: url)
            case (_, .stream):
                throw URLSessionClientError.uploadStreamUnimplemented
            }
            
            info.data = result.data
            info.response = result.response
            
            return try endpoint.content(from: result.response, with: result.data)
        } catch {
            Task.detached { [weak self, info] in
                self?.observeResponse(info: info, error: error)
            }
            throw error
        }
    }
}
