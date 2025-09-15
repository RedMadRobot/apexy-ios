//
//  AlamofireClient.swift
//
//  Created by Alexander Ignatev on 12/02/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import Alamofire
import Apexy
import Foundation

/// API Client.
@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
open class AlamofireClient: Client, CombineClient {

    /// Session network manager.
    let sessionManager: Alamofire.Session

    /// The queue on which the network response handler is dispatched.
    let responseQueue = DispatchQueue(
        label: "Apexy.responseQueue",
        qos: .utility)

    /// The queue on which the completion handler is dispatched.
    let completionQueue: DispatchQueue

    /// This closure to be called after each response from the server for the request.
    let responseObserver: ResponseObserver?

    /// Look more at Alamofire.RequestInterceptor.
    let requestInterceptor: RequestInterceptor

    /// Creates new 'AlamofireClient' instance.
    ///
    /// - Parameters:
    ///   - requestInterceptor: Alamofire Request Interceptor.
    ///   - configuration: The configuration used to construct the managed session.
    ///   - completionQueue: The serial operation queue used to dispatch all completion handlers. `.main` by default.
    ///   - publicKeys:  Dictionary with 1..n public keys used for SSL-pinning: ["example1.com": [PK1], "example2": [PK2, PK3]].
    ///   - responseObserver: The closure to be called after each response.
    ///   - eventMonitors: Alamofire `EventMonitor`s used by the instance. `[]` by default.
    public init(
        requestInterceptor: RequestInterceptor,
        configuration: URLSessionConfiguration,
        completionQueue: DispatchQueue = .main,
        publicKeys: [String: [SecKey]] = [:],
        evaluateAllHostsForTrust: Bool = true,
        responseObserver: ResponseObserver? = nil,
        eventMonitors: [EventMonitor] = []) {

        var securityManager: ServerTrustManager?
        /// All requests will cancelled if `ServerTrustManager` will initialized with empty evaluators
        if !publicKeys.isEmpty {
            let evaluators = publicKeys.mapValues { keys in
                return PublicKeysTrustEvaluator(keys: keys, performDefaultValidation: true, validateHost: true)
            }
            securityManager = ServerTrustManager(allHostsMustBeEvaluated: evaluateAllHostsForTrust, evaluators: evaluators)
        }

        self.completionQueue = completionQueue
        self.requestInterceptor = requestInterceptor
        self.sessionManager = Session(
            configuration: configuration,
            interceptor: requestInterceptor,
            serverTrustManager: securityManager,
            eventMonitors: eventMonitors)
        self.responseObserver = responseObserver
    }
    
    /// Creates new 'AlamofireClient' instance.
    ///
    /// - Parameters:
    ///   - baseURL: Base `URL`.
    ///   - configuration: The configuration used to construct the managed session.
    ///   - completionQueue: The serial operation queue used to dispatch all completion handlers. `.main` by default.
    ///   - publicKeys: Dictionary with 1..n public keys used for SSL-pinning: ["example1.com": [PK1], "example2": [PK2, PK3]].
    ///   - responseObserver: The closure to be called after each response.
    ///   - eventMonitors: Alamofire `EventMonitor`s used by the instance. `[]` by default.
    public convenience init(
        baseURL: URL,
        configuration: URLSessionConfiguration,
        completionQueue: DispatchQueue = .main,
        publicKeys: [String: [SecKey]] = [:],
        evaluateAllHostsForTrust: Bool = true,
        responseObserver: ResponseObserver? = nil,
        eventMonitors: [EventMonitor] = []) {
        self.init(
            requestInterceptor: BaseRequestInterceptor(baseURL: baseURL),
            configuration: configuration,
            completionQueue: completionQueue,
            publicKeys: publicKeys,
            evaluateAllHostsForTrust: evaluateAllHostsForTrust,
            responseObserver: responseObserver,
            eventMonitors: eventMonitors)
    }

    func observeResponse(
        dataResponse: DataResponse<Data, AFError>,
        error: Error?) {
            self.responseObserver?(
                dataResponse.request,
                dataResponse.response,
                dataResponse.data,
                error)
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

        Task.detached { [weak self, dataResponse, result] in
            self?.observeResponse(dataResponse: dataResponse, error: result.error)
        }

        return try result.get()
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

        Task.detached { [weak self, dataResponse, result] in
            self?.observeResponse(dataResponse: dataResponse, error: result.error)
        }

        return try result.get()
    }

}

// MARK: - Helper

/// Wrapper for `URLRequestConvertible` from `Alamofire`.
struct AnyRequest: Alamofire.URLRequestConvertible {
    let create: () throws -> URLRequest

    func asURLRequest() throws -> URLRequest {
        return try create()
    }
}

public extension Error {
    func unwrapAlamofireValidationError() -> Error {
        guard let afError = asAFError else { return self }
        if case .responseValidationFailed(let reason) = afError,
           case .customValidationFailed(let underlyingError) = reason {
            return underlyingError
        }
        return self
    }
}
