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
        
        let anyRequest = AnyRequest(create: endpoint.makeRequest)
        let request = sessionManager.request(anyRequest)
            .validate { request, response, data in
                Result(catching: { try endpoint.validate(request, response: response, data: data) })
            }

        let dataResponse = await request.serializingData().response
        let result = APIResult<T.Content>(catching: { () throws -> T.Content in
            do {
                let data = try dataResponse.result.get()
                return try endpoint.content(from: dataResponse.response, with: data)
            } catch {
                throw error.unwrapAlamofireValidationError()
            }
        })

        Task.detached {[weak self] in
            await self?.observeResponse(
                request: dataResponse.request,
                response: dataResponse.response,
                data: dataResponse.data,
                error: result.error)
        }

        do {
            return try result.get()
        } catch {
            throw error
        }
    }
    
    open func upload<T>(_ endpoint: T) async throws -> T.Content where T : UploadEndpoint {
        
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

        let dataResponse = await request.serializingData().response
        let result = APIResult<T.Content>(catching: { () throws -> T.Content in
            do {
                let data = try dataResponse.result.get()
                return try endpoint.content(from: dataResponse.response, with: data)
            } catch {
                throw error.unwrapAlamofireValidationError()
            }
        })

        Task.detached {[weak self] in
            await self?.observeResponse(
                request: dataResponse.request,
                response: dataResponse.response,
                data: dataResponse.data,
                error: result.error)
        }

        do {
            return try result.get()
        } catch {
            throw error
        }
    }
}