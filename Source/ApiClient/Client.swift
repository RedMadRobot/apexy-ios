//
//  Client.swift
//
//  Created by Alexander Ignatev on 12/02/2019.
//  Copyright © 2019 RedMadRobot. All rights reserved.
//

import Alamofire
import Foundation

public typealias APIResult<Value> = Swift.Result<Value, Error>

/// Клиент для работы со Smart home API.
public final class Client {

    public typealias ResponseObserver = (URLRequest?, HTTPURLResponse?, Data?, Error?) -> Void

    /// Менеджер сетевой сессии.
    private let sessionManager: Alamofire.SessionManager

    /// Очередь ответов сервера.
    private let responseQueue = DispatchQueue(
        label: "ApiClient.responseQueue",
        qos: .utility)

    /// Очередь колбеков с результатом.
    private let completionQueue: DispatchQueue

    /// Наблюдатель за всеми ответами API.
    private let responseObserver: ResponseObserver?

    /// Адаптер запросов.
    public let requestAdapter: RequestAdapter

    /// Создать нового клиента API.
    ///
    /// - Parameters:
    ///   - requestAdapter: Адаптер запросов.
    ///   - configuration: Конфигурация сетевой сессии.
    ///   - completionQueue: Очередь колбеков с результатом.
    ///   - publicKeys: Список доменов и публичных ключей для SSL-пиннинга
    ///   - responseObserver: Наблюдатель за всеми ответами API.
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
    
    /// Создать нового клиента API.
    ///
    /// - Parameters:
    ///   - baseURL: Базовый `URL` API.
    ///   - configuration: Конфигурация сетевой сессии.
    ///   - completionQueue: Очередь колбеков с результатом.
    ///   - publicKeys: Список доменов и публичных ключей для SSL-пиннинга
    ///   - responseObserver: Наблюдатель за всеми ответами API.
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

    /// Отправить запрос к API.
    ///
    /// - Parameters:
    ///   - endpoint: Конечная точка запроса.
    ///   - completionHandler: Обработчик результата запроса.
    /// - Returns: Прогресс выполнения запроса.
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

    // MARK: - Private

    private func progress(for request: Alamofire.Request) -> Progress {
        let progress = Progress()
        progress.cancellationHandler = request.cancel
        return progress
    }
}

// MARK: - Helper

/// Обёртка над протоколом `URLRequestConvertible` из `Alamofire`.
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
