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
    public init(
        baseURL: URL,
        configuration: URLSessionConfiguration = .default,
        completionQueue: DispatchQueue = .main,
        responseObserver: ResponseObserver? = nil) {
        
        self.requestAdapter = BaseRequestAdapter(baseURL: baseURL)
        self.session = URLSession(configuration: configuration)
        self.completionQueue = completionQueue
        self.responseObserver = responseObserver
    }
    
    open func request<T>(
        _ endpoint: T,
        completionHandler: @escaping (Result<T.Content, T.Failure>) -> Void) -> Progress where T : Endpoint {
        
        let urlRequestResult = endpoint.makeRequest()
        guard case let .success(urlRequest) = urlRequestResult else {
            if case let .failure(error) = urlRequestResult {
                self.completionQueue.async {
                    completionHandler(.failure(error))
                }
            }
            return Progress()
        }
        let request: URLRequest
        do {
            request = try requestAdapter.adapt(urlRequest)
        } catch {
            self.completionQueue.async {
                completionHandler(endpoint.decode(fromResponse: nil, withResult: .failure(error)))
            }
            return Progress()
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in

            let dataResult: Result<Data, Error>
            if let data = data {
                dataResult = .success(data)
            } else {
                if let error = error {
                    dataResult = .failure(error)
                } else {
                    dataResult = .failure(URLSessionClientError.badResponse)
                }
            }
            let httpResponse = response as? HTTPURLResponse
            let result = endpoint.decode(fromResponse: httpResponse, withResult: dataResult)

            self.completionQueue.async {
                self.responseObserver?(request, response as? HTTPURLResponse, data, error)
                completionHandler(result)
            }
        }
        task.resume()
        
        return task.progress
    }
    
    open func upload<T>(_ endpoint: T, completionHandler: @escaping (Result<T.Content, T.Failure>) -> Void) -> Progress where T : UploadEndpoint {

        let urlRequestResult = endpoint.makeRequest()
        guard case let .success(urlRequestTuple) = urlRequestResult else {
            if case let .failure(error) = urlRequestResult {
                completionHandler(.failure(error))
            }
            return Progress()
        }
        let request: (URLRequest, UploadEndpointBody)
        do {
            request = (try requestAdapter.adapt(urlRequestTuple.0), urlRequestTuple.1)
        } catch {
            completionHandler(endpoint.decode(fromResponse: nil, withResult: .failure(error)))
            return Progress()
        }
        
        let handler: (Data?, URLResponse?, Error?) -> Void = { (data, response, error) in
            
            let dataResult: Result<Data, Error>
            if let data = data {
                dataResult = .success(data)
            } else {
                if let error = error {
                    dataResult = .failure(error)
                } else {
                    dataResult = .failure(URLSessionClientError.badResponse)
                }
            }
            let httpResponse = response as? HTTPURLResponse
            let result = endpoint.decode(fromResponse: httpResponse, withResult: dataResult)

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
            completionHandler(
                endpoint.decode(
                    fromResponse: nil,
                    withResult: .failure(URLSessionClientError.uploadStreamUnimplemented)))
            return Progress()
        }
        task.resume()
        
        return task.progress
    }
}

enum URLSessionClientError: LocalizedError {
    case uploadStreamUnimplemented
    case badResponse
    
    var errorDescription: String? {
        switch self {
        case .uploadStreamUnimplemented:
            return """
            UploadEndpointBody.stream is unimplemented. If you need it feel free to create an issue \
            on GitHub https://github.com/RedMadRobot/apexy-ios/issues/new
            """
        case .badResponse:
            return """
            Request adaption has failed. If you need it feel free to create an issue \
            on GitHub https://github.com/RedMadRobot/apexy-ios/issues/new
            """
        }
    }
}
