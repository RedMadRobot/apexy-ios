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
        
    func observeResponse(
        request: URLRequest?,
        response: HTTPURLResponse?,
        data: Data?,
        error: Error?) async {
            
            return await withCheckedContinuation{ continuation in
                completionQueue.async {[weak self] in
                    self?.responseObserver?(request, response, data, error)
                    continuation.resume()
                }
            }
        }
    
    open func request<T>(_ endpoint: T) async throws -> T.Content where T : Endpoint {
        
        var request = try endpoint.makeRequest()
        request = try requestAdapter.adapt(request)
        var responseResult: Result<(data: Data, response: URLResponse), Error>
        
        do {
            let response: (data: Data, response: URLResponse) = try await session.data(for: request)
            
            if let httpResponse = response.response as? HTTPURLResponse {
                try endpoint.validate(request, response: httpResponse, data: response.data)
            }
            
            responseResult = .success(response)
        } catch let someError {
            responseResult = .failure(someError)
        }
        
        Task.detached {[weak self, request, responseResult] in
            let tuple = try? responseResult.get()
            await self?.observeResponse(
                request: request,
                response: tuple?.response as? HTTPURLResponse,
                data: tuple?.data,
                error: responseResult.error)
        }
        
        return try responseResult.flatMap { tuple in
            do {
                return .success(try endpoint.content(from: tuple.response, with: tuple.data))
            } catch {
                return .failure(error)
            }
        }.get()
    }
    
    open func upload<T>(_ endpoint: T) async throws -> T.Content where T : UploadEndpoint {
        
        var request: (request: URLRequest, body: UploadEndpointBody) = try endpoint.makeRequest()
        request.request = try requestAdapter.adapt(request.request)
        var responseResult: Result<(data: Data, response: URLResponse), Error>
        
        do {
            let response: (data: Data, response: URLResponse)
            switch request {
            case (_, .data(let data)):
                response = try await session.upload(for: request.request, from: data)
            case (_, .file(let url)):
                response = try await session.upload(for: request.request, fromFile: url)
            case (_, .stream):
                throw URLSessionClientError.uploadStreamUnimplemented
            }
            
            responseResult = .success(response)
        } catch let someError {
            responseResult = .failure(someError)
        }
        
        
        Task.detached {[weak self, request, responseResult] in
            let tuple = try? responseResult.get()
            await self?.observeResponse(
                request: request.request,
                response: tuple?.response as? HTTPURLResponse,
                data: tuple?.data,
                error: responseResult.error)
        }
        
        return try responseResult.flatMap { tuple in
            do {
                return .success(try endpoint.content(from: tuple.response, with: tuple.data))
            } catch {
                return .failure(error)
            }
        }.get()
    }
}
