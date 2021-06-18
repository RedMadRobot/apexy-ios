//
//  BaseRequestInterceptor.swift
//
//  Created by Alexander Ignatev on 12/02/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import Alamofire
import Foundation

/// Implementation of Alamofire.RequestInterceptor.
open class BaseRequestInterceptor: Alamofire.RequestInterceptor {
    
    /// Contains Base `URL`.
    ///
    /// Must end with a slash character `https://example.com/api/v1/`
    ///
    /// - Warning: declared as open variable for debug purposes only.
    open var baseURL: URL
    
    /// Creates a `BaseRequestInterceptor` instance with specified Base `URL`.
    ///
    /// - Parameter baseURL: Base `URL` for adapter.
    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    // MARK: - Alamofire.RequestInterceptor
    
    open func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void) {

        guard let url = urlRequest.url else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = urlRequest
        request.url = appendingBaseURL(to: url)
        
        completion(.success(request))
    }
    
    open func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void) {
        
        return completion(.doNotRetry)
    }
    
    // MARK: - Private
    
    private func appendingBaseURL(to url: URL) -> URL {
        URL(string: url.absoluteString, relativeTo: baseURL)!
    }

}
