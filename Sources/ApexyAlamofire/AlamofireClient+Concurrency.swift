//
//  AlamofireClient+Concurrency.swift
//  
//
//  Created by Aleksei Tiurnin on 15.08.2022.
//

import Alamofire
import Apexy
import Foundation

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
extension AlamofireClient: ConcurrencyClient {
    
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
            let anyRequest = AnyRequest(create: endpoint.makeRequest)
            let request = sessionManager.request(anyRequest)
                .validate { request, response, data in
                    Result(catching: { try endpoint.validate(request, response: response, data: data) })
                }
            
            info.request = request.request
            
            let dataResponse = await request.serializingData().response
            
            info.data = dataResponse.data
            info.response = dataResponse.response
            
            let data = try dataResponse.result.get()
            return try endpoint.content(from: dataResponse.response, with: data)
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
            let urlRequest: URLRequest
            let body: UploadEndpointBody
            (urlRequest, body) = try endpoint.makeRequest()
            
            let request: UploadRequest
            switch body {
            case .data(let data):
                request = sessionManager.upload(data, with: urlRequest)
            case .file(let url):
                request = sessionManager.upload(url, with: urlRequest)
            case .stream(let stream):
                request = sessionManager.upload(stream, with: urlRequest)
            }
            
            info.request = request.request
            
            let dataResponse = await request.serializingData().response
            
            info.data = dataResponse.data
            info.response = dataResponse.response
            
            let data = try dataResponse.result.get()
            return try endpoint.content(from: dataResponse.response, with: data)
        } catch {
            Task.detached { [weak self, info] in
                self?.observeResponse(info: info, error: error)
            }
            throw error
        }
    }
}
