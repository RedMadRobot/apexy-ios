//
//  BaseRequestAdapter.swift
//
//  Created by Alexander Ignatev on 12/02/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import Alamofire
import Foundation

/// Адаптер запросов к API.
open class BaseRequestAdapter: Alamofire.RequestAdapter {

    /// Базовый `URL` API.
    ///
    /// - Warning: Возможность обновления только для отдлаки.
    open var baseURL: URL

    /// Создать адаптер с базовым `URL`.
    ///
    /// - Parameter baseURL: Базовый `URL`
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
