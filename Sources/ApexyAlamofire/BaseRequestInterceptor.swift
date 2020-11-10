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
    /// - Warning: declared as open variable for debug purposes only.
    open var baseURL: URL
    
    /// Creates a `BaseRequestInterceptor` instance with specified Base `URL`.
    ///
    /// - Parameter baseURL: Base `URL` for adapter.
    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    // MARK: - Alamofire.RequestInterceptor
    
    public func adapt(
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
    
    public func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void) {
        
        return completion(.doNotRetryWithError(error))
    }
    
    // MARK: - Private
    
    private func appendingBaseURL(to url: URL) -> URL {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        components.percentEncodedQuery = url.query
        return components.url!.appendingPathComponent(url.path)
    }

}
