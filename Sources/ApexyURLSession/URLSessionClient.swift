import Foundation
import Apexy

open class URLSessionClient: Client {
    
    /// A closure used to observe result of every response from the server.
    public typealias ResponseObserver = (URLRequest?, HTTPURLResponse?, Data?, Error?) -> Void

    private let session: URLSession
    
    private let requestAdapter: RequestAdapter

    /// The queue on which the completion handler is dispatched.
    private let completionQueue: DispatchQueue

    /// This closure to be called after each response from the server for the request.
    private let responseObserver: ResponseObserver?
    
    /// Creates new 'URLSessionClient' instance.
    ///
    /// - Parameters:
    ///   - baseURL: Base `URL`.
    ///   - configuration: The configuration used to construct the managed session.
    ///   - completionQueue: The serial operation queue used to dispatch all completion handlers. `.main` by default.
    ///   - responseObserver: The closure to be called after each response.
    public convenience init(
        baseURL: URL,
        configuration: URLSessionConfiguration = .default,
        completionQueue: DispatchQueue = .main,
        responseObserver: ResponseObserver? = nil) {
        
        self.init(
            requestAdapter: BaseRequestAdapter(baseURL: baseURL),
            configuration: configuration,
            completionQueue: completionQueue,
            responseObserver: responseObserver)
    }
    
    /// Creates new 'URLSessionClient' instance.
    ///
    /// - Parameters:
    ///   - requestAdapter: RequestAdapter used to adapt a `URLRequest`.
    ///   - configuration: The configuration used to construct the managed session.
    ///   - completionQueue: The serial operation queue used to dispatch all completion handlers. `.main` by default.
    ///   - responseObserver: The closure to be called after each response.
    public init(
        requestAdapter: RequestAdapter,
        configuration: URLSessionConfiguration = .default,
        completionQueue: DispatchQueue = .main,
        responseObserver: ResponseObserver? = nil) {
        
        self.requestAdapter = requestAdapter
        self.session = URLSession(configuration: configuration)
        self.completionQueue = completionQueue
        self.responseObserver = responseObserver
    }
    
    open func request<T>(
        _ endpoint: T,
        completionHandler: @escaping (APIResult<T.Content>) -> Void) -> Progress where T : Endpoint {
        
        var request: URLRequest
        do {
            request = try endpoint.makeRequest()
            request = try requestAdapter.adapt(request)
        } catch {
            completionHandler(.failure(error))
            return Progress()
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            let result = APIResult<T.Content>(catching: { () throws -> T.Content in
                if let httpResponse = response as? HTTPURLResponse {
                    try endpoint.validate(request, response: httpResponse, data: data)
                }
                let data = data ?? Data()
                if let error = error {
                    throw error
                }
                return try endpoint.content(from: response, with: data)
            })
            self.completionQueue.async {
                self.responseObserver?(request, response as? HTTPURLResponse, data, error)
                completionHandler(result)
            }
        }
        task.resume()
        
        return task.progress
    }
    
    open func upload<T>(_ endpoint: T, completionHandler: @escaping (APIResult<T.Content>) -> Void) -> Progress where T : UploadEndpoint {
        var request: (URLRequest, UploadEndpointBody)
        do {
            request = try endpoint.makeRequest()
            request.0 = try requestAdapter.adapt(request.0)
        } catch {
            completionHandler(.failure(error))
            return Progress()
        }
        
        let handler: (Data?, URLResponse?, Error?) -> Void = { (data, response, error) in
            let result = APIResult<T.Content>(catching: { () throws -> T.Content in
                let data = data ?? Data()
                if let error = error {
                    throw error
                }
                return try endpoint.content(from: response, with: data)
            })
            self.completionQueue.async {
                self.responseObserver?(request.0, response as? HTTPURLResponse, data, error)
                completionHandler(result)
            }
        }
        
        let task: URLSessionUploadTask
        switch request {
        case (let request, .data(let data)):
            task = session.uploadTask(with: request, from: data, completionHandler: handler)
        case (let request, .file(let url)):
            task = session.uploadTask(with: request, fromFile: url, completionHandler: handler)
        case (_, .stream):
            completionHandler(.failure(URLSessionClientError.uploadStreamUnimplemented))
            return Progress()
        }
        task.resume()
        
        return task.progress
    }
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    open func request<T>(_ endpoint: T) async throws -> T.Content where T : Endpoint {
        var request = try endpoint.makeRequest()
        request = try requestAdapter.adapt(request)
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            try endpoint.validate(request, response: httpResponse, data: data)
        }
        
        responseObserver?(request, response as? HTTPURLResponse, data, nil)
        
        return try endpoint.content(from: response, with: data)
    }
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    open func upload<T>(_ endpoint: T) async throws -> T.Content where T : UploadEndpoint {
        var request = try endpoint.makeRequest()
        request.0 = try requestAdapter.adapt(request.0)
        
        let response: (Data, URLResponse)
        switch request {
        case (let request, .data(let data)):
            response = try await session.upload(for: request, from: data)
        case (let request, .file(let url)):
            response = try await session.upload(for: request, fromFile: url)
        case (_, .stream):
            throw URLSessionClientError.uploadStreamUnimplemented
        }
        
        responseObserver?(request.0, response.1 as? HTTPURLResponse, response.0, nil)
        
        return try endpoint.content(from: response.1, with: response.0)
    }
    
}

enum URLSessionClientError: LocalizedError {
    case uploadStreamUnimplemented
    
    var errorDescription: String? {
        switch self {
        case .uploadStreamUnimplemented:
            return """
            UploadEndpointBody.stream is unimplemented. If you need it feel free to create an issue \
            on GitHub https://github.com/RedMadRobot/apexy-ios/issues/new
            """
        }
    }
}
