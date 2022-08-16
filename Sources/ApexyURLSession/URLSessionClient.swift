import Apexy
import Foundation

open class URLSessionClient: Client, ConcurrencyClient, CombineClient {
    
    /// A closure used to observe result of every response from the server.
    public typealias ResponseObserver = (URLRequest?, HTTPURLResponse?, Data?, Error?) -> Void

    let session: URLSession
    
    let requestAdapter: RequestAdapter

    /// The queue on which the completion handler is dispatched.
    let completionQueue: DispatchQueue

    /// This closure to be called after each response from the server for the request.
    let responseObserver: ResponseObserver?
    
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
