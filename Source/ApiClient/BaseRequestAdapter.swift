//
//  BaseRequestAdapter.swift
//
//  Created by Alexander Ignatev on 12/02/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import Alamofire
import Foundation

/// Implementation of Alamofire.RequestAdapter.
open class BaseRequestAdapter: Alamofire.RequestAdapter {

    /// Contains Base `URL`.
    ///
    /// - Warning: declared as open variable for debug purposes only.
    open var baseURL: URL

    /// Creates a `BaseRequestAdapter` instance with specified Base `URL`.
    ///
    /// - Parameter baseURL: Base `URL` for adapter.
    public init(baseURL: URL) {
        self.baseURL = baseURL
    }

    // MARK: - Alamofire.RequestAdapter

    open func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        guard let url = urlRequest.url else { return urlRequest }

        var request = urlRequest
        request.url = appendingBaseURL(to: url)

        return request
    }

    // MARK: - Private

    private func appendingBaseURL(to url: URL) -> URL {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        components.percentEncodedQuery = url.query
        return components.url!.appendingPathComponent(url.path)
    }
}
