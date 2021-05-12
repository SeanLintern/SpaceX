import UIKit

typealias ImageLoadingCompletion = ((_ image: UIImage?) -> Void)

private typealias URLLoadingComplete = ((_ image: UIImage?, _ resource: URL) -> Void)

private class ImageLoadingRequestOperation: Operation {
    
    var resource: URL
    private var session: URLSession
    private var completion: URLLoadingComplete?

    override var isAsynchronous: Bool {
        return true
    }
    
    override var isExecuting: Bool {
        return !completed
    }
    
    override var isFinished: Bool {
        return completed
    }
    
    override var isCancelled: Bool {
        return completed
    }
    
    /// Prevents the operation reporting as completed through super methods
    /// before the async operation is actually complete.
    private var completed: Bool = false
    private var task: URLSessionDataTask?
    
    init(resource: URL, session: URLSession, completion: URLLoadingComplete?) {
        self.resource = resource
        self.session = session
        self.completion = completion
    }
    
    override func start() {
        super.start()
        
        guard !isCancelled else {
            completion?(nil, resource)
            completed = true
            return
        }
        
        task = session.dataTask(with: resource) { [weak self] (data, _, _) in
            self?.complete(data: data)
        }
        
        task?.resume()
    }
    
    private func complete(data: Data?) {
        guard !isCancelled else { // been cancelled
            completion?(nil, resource)
            completed = true
            return
        }
        
        guard let imageData = data else {
            completion?(nil, resource)
            completed = true
            return
        }
        
        completion?(UIImage(data: imageData), resource)
        completed = true
    }
    
    override func cancel() {
        task?.cancel()
        complete(data: nil)
        super.cancel()
    }
}

class ImageLoader {
    
    private var cache: NSCache<AnyObject, UIImage>
    
    private var requestQueue: OperationQueue
    
    private var requestStore = [String: [ImageLoadingCompletion?]]()
    
    private var session: URLSession
    
    static let shared = ImageLoader(cache: NSCache(), queue: OperationQueue(), session: URLSession.shared)
    
    init(cache: NSCache<AnyObject, UIImage>, queue: OperationQueue, session: URLSession) {
        self.cache = cache
        self.requestQueue = queue
        self.session = session
        
        queue.qualityOfService = .background
    }
    
    func request(resource: URL, completion: ImageLoadingCompletion?) {
        if let cachedImage = cache.object(forKey: resource.identifier as AnyObject) {
            completion?(cachedImage)
            return
        }
        if var existingRequests = requestStore[resource.identifier] {
            existingRequests.append(completion)
            requestStore[resource.identifier] = existingRequests
            return
        }
        
        let newRequest = ImageLoadingRequestOperation(resource: resource, session: session, completion: { [weak self] image, resource in
            self?.requestCompleted(image: image, resource: resource)
        })
        requestStore[resource.identifier] = [completion]
        requestQueue.addOperation(newRequest)
    }
    
    func cancelRequest(resource: URL) {
        requestQueue.operations.forEach({
            if let op = $0 as? ImageLoadingRequestOperation, op.resource.identifier == resource.identifier {
                $0.cancel()
            }
        })
    }
    
    private func requestCompleted(image: UIImage?, resource: URL) {
        let requests = requestStore[resource.identifier]
        
        for request in requests ?? [] {
            DispatchQueue.main.async {
                request?(image)
            }
        }
        
        requestStore[resource.identifier] = nil
        
        guard let verifiedImage = image else { return }
        
        cache.setObject(verifiedImage, forKey: resource.identifier as AnyObject)
    }
}

extension URL {
    var identifier: String {
        return lastPathComponent
    }
}
