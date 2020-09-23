import Foundation
import Apexy

final public class URLSessionClient: Client {
    
    /// A closure used to observe result of every response from the server.
    public typealias ResponseObserver = (URLRequest?, HTTPURLResponse?, Data?, Error?) -> Void

    private let session: URLSession
    
    private let requestAdapter: RequestAdapter

    /// The queue on which the completion handler is dispatched.
    private let completionQueue: DispatchQueue

    /// This closure to be called after each response from the server for the request.
    private let responseObserver: ResponseObserver?

    private let sessionDelegate = SessionDelegate()
    
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
        self.session = URLSession(configuration: configuration, delegate: sessionDelegate, delegateQueue: .main)
        self.completionQueue = completionQueue
        self.responseObserver = responseObserver
    }
    
    public func request<T>(
        _ endpoint: T,
        completionHandler: @escaping (APIResult<T.Content>) -> Void) -> Progress where T : Endpoint {
        
        var request: URLRequest
        do {
            request = try endpoint.makeRequest()
            request = try requestAdapter.adapt(request).get()
        } catch {
            completionHandler(.failure(error))
            return Progress()
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            let result = APIResult<T.Content>(catching: { () throws -> T.Content in
                if let data = data {
                    return try endpoint.content(from: response, with: data)
                } else {
                    throw error!
                }
            })
            self.completionQueue.async {
                self.responseObserver?(request, response as? HTTPURLResponse, data, error)
                completionHandler(result)
            }
        }
        task.resume()
        
        return task.progress
    }
    
    public func upload<T>(_ endpoint: T, completionHandler: @escaping (APIResult<T.Content>) -> Void) -> Progress where T : UploadEndpoint {
        var request: (URLRequest, UploadEndpointBody)
        do {
            request = try endpoint.makeRequest()
            request.0 = try requestAdapter.adapt(request.0).get()
        } catch {
            completionHandler(.failure(error))
            return Progress()
        }
        
        let handler: (Data?, URLResponse?, Error?) -> Void = { (data, response, error) in
            let result = APIResult<T.Content>(catching: { () throws -> T.Content in
                if let data = data {
                    return try endpoint.content(from: response, with: data)
                } else {
                    throw error!
                }
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
        case (let request, .stream(let inputStream)):
            task = session.uploadTask(withStreamedRequest: request)
            var uploadTask: UploadTask!
            uploadTask = UploadTask(task: task, inputStream: inputStream) { [weak self] result in
                switch result {
                case .success(let data):
                    handler(data, task.response, nil)
                case .failure(let error):
                    handler(nil, task.response, error)
                }
                self?.sessionDelegate.deleteUploadTask(uploadTask)
            }
            sessionDelegate.appendUploadTask(uploadTask)
        }
        task.resume()
        
        return task.progress
    }
}

private final class UploadTask {
    
    let task: URLSessionUploadTask
    let inputStream: InputStream
    let completionHandler: (Result<Data, Error>) -> Void
    let progress: Progress = Progress()
    
    init(task: URLSessionUploadTask, inputStream: InputStream, completionHandler: @escaping (Result<Data, Error>) -> Void) {
        self.task = task
        self.inputStream = inputStream
        self.completionHandler = completionHandler
    }
}

private final class SessionDelegate: NSObject {
    
    private var tasks: [UploadTask] = []
    
    func appendUploadTask(_ task: UploadTask) {
        tasks.append(task)
    }
    
    func deleteUploadTask(_ task: UploadTask) {
        if let index = tasks.firstIndex(where: { $0 === task }) {
            tasks.remove(at: index)
        }
    }
}

// MARK: - URLSessionTaskDelegate

extension SessionDelegate: URLSessionTaskDelegate {
    
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
        
        let uploadTask = tasks.first(where: { $0.task === task })
        completionHandler(uploadTask?.inputStream)
    }
    
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64) {
        
        let uploadTask = tasks.first(where: { $0.task === task })
        uploadTask?.progress.totalUnitCount = totalBytesExpectedToSend
        uploadTask?.progress.completedUnitCount = totalBytesSent
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let uploadTask = tasks.first(where: { $0.task === task }), let error = error else { return }
        uploadTask.completionHandler(.failure(error))
    }
}

// MARK: - URLSessionDataDelegate

extension SessionDelegate: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let uploadTask = tasks.first(where: { $0.task === dataTask })
        uploadTask?.completionHandler(.success(data))
    }
}
