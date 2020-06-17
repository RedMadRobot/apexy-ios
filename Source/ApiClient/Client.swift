//
//  Client.swift
//
//  Created by Alexander Ignatev on 12/02/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import Alamofire
import Foundation

public typealias APIResult<Value> = Swift.Result<Value, Error>

/// API Client.
public final class Client {

    /// A closure used to observe result of every response from the server.
    public typealias ResponseObserver = (URLRequest?, HTTPURLResponse?, Data?, Error?) -> Void

    /// Session network manager.
    private let sessionManager: Alamofire.SessionManager

    /// The queue on which the network response handler is dispatched.
    private let responseQueue = DispatchQueue(
        label: "ApiClient.responseQueue",
        qos: .utility)

    /// The queue on which the completion handler is dispatched.
    private let completionQueue: DispatchQueue

    /// This closure to be called after each response from the server for the request.
    private let responseObserver: ResponseObserver?

    /// Look more at Alamofire.RequestAdapter.
    public let requestAdapter: RequestAdapter

    /// Creates new 'Client' instance.
    ///
    /// - Parameters:
    ///   - requestAdapter: Alamofire Request Adapter.
    ///   - configuration: The configuration used to construct the managed session.
    ///   - completionQueue: The serial operation queue used to dispatch all completion handlers. `.main` by default.
    ///   - publicKeys:  Dictionary with 1..n public keys used for SSL-pinning: ["example1.com": [PK1], "example2": [PK2, PK3]].
    ///   - responseObserver: The closure to be called after each response.
    public init(
        requestAdapter: RequestAdapter,
        configuration: URLSessionConfiguration,
        completionQueue: DispatchQueue = .main,
        publicKeys: [String: [SecKey]] = [:],
        responseObserver: ResponseObserver? = nil) {

        let securityManager = ServerTrustPolicyManager(policies: publicKeys.mapValues { keys in
            return ServerTrustPolicy.pinPublicKeys(
                publicKeys: keys,
                validateCertificateChain: true,
                validateHost: true)
        })

        self.completionQueue = completionQueue
        self.requestAdapter = requestAdapter
        self.sessionManager = SessionManager(
            configuration: configuration,
            serverTrustPolicyManager: securityManager)
        self.sessionManager.adapter = requestAdapter
        self.responseObserver = responseObserver
    }
    
    /// Creates new 'Client' instance.
    ///
    /// - Parameters:
    ///   - baseURL: Base `URL`.
    ///   - configuration: The configuration used to construct the managed session.
    ///   - completionQueue: The serial operation queue used to dispatch all completion handlers. `.main` by default.
    ///   - publicKeys: Dictionary with 1..n public keys used for SSL-pinning: ["example1.com": [PK1], "example2": [PK2, PK3]].
    ///   - responseObserver: The closure to be called after each response.
    public convenience init(
        baseURL: URL,
        configuration: URLSessionConfiguration,
        completionQueue: DispatchQueue = .main,
        publicKeys: [String: [SecKey]] = [:],
        responseObserver: ResponseObserver? = nil) {
        self.init(
            requestAdapter: BaseRequestAdapter(baseURL: baseURL),
            configuration: configuration,
            completionQueue: completionQueue,
            publicKeys: publicKeys,
            responseObserver: responseObserver)
    }

    /// Send request to specified endpoint.
    ///
    /// - Parameters:
    ///   - endpoint: endpoint of remote content.
    ///   - completionHandler: The completion closure to be executed when request is completed.
    /// - Returns: The progress of fetching the response data from the server for the request.
    public func request<T>(
        _ endpoint: T,
        completionHandler: @escaping (APIResult<T.Content>) -> Void
    ) -> Progress where T: Endpoint {

        let anyRequest = AnyRequest(create: endpoint.makeRequest)
        let request = sessionManager.request(anyRequest).responseData(
            queue: responseQueue,
            completionHandler: { (response: DataResponse<Data>) in

                let result = APIResult<T.Content>(catching: { () throws -> T.Content in
                    let data = try response.result.unwrap()
                    return try endpoint.content(from: response.response, with: data)
                })

                self.completionQueue.async {
                    self.responseObserver?(response.request, response.response, response.data, result.error)
                    completionHandler(result)
                }
            })

        return progress(for: request)
    }
    
    public func upload<T>(
        _ endpoint: T,
        completionHandler: @escaping (APIResult<T.Content>) -> Void
    ) -> Progress where T: UploadEndpoint {
        
        let anyRequest = AnyRequest(create: endpoint.makeRequest)
        let request: UploadRequest
        
        switch endpoint.dataToUpload {
        case .data(let data):
            request = sessionManager.upload(data, with: anyRequest)
        case .file(let url):
            request = sessionManager.upload(url, with: anyRequest)
        case .stream(let stream):
            request = sessionManager.upload(stream, with: anyRequest)
        }
        
        request.responseData(
            queue: responseQueue,
            completionHandler: { (response: DataResponse<Data>) in

                let result = APIResult<T.Content>(catching: { () throws -> T.Content in
                    let data = try response.result.unwrap()
                    return try endpoint.content(from: response.response, with: data)
                })

                self.completionQueue.async {
                    self.responseObserver?(response.request, response.response, response.data, result.error)
                    completionHandler(result)
                }
            })

        return progress(for: request)
    }

    // MARK: - Private

    private func progress(for request: Alamofire.Request) -> Progress {
        let progress = Progress()
        progress.cancellationHandler = request.cancel
        return progress
    }
}

// MARK: - Helper

/// Wrapper for `URLRequestConvertible` from `Alamofire`.
private struct AnyRequest: Alamofire.URLRequestConvertible {
    let create: () throws -> URLRequest

    func asURLRequest() throws -> URLRequest {
        return try create()
    }
}

private extension APIResult {
    var error: Error? {
        switch self {
        case .failure(let error):
            return error
        default:
            return nil
        }
    }
}
