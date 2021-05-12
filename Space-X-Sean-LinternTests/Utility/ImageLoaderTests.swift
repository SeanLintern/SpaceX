import XCTest
@testable import Space_X_Sean_Lintern

class ImageLoaderTests: XCTestCase {
    
    private var testCache: NSCache<AnyObject, UIImage>!
    private var testLoader: ImageLoader!
    private var testQueue: OperationQueue!
    private var testImageView: UIImageView?

    override func setUp() {
        testCache = NSCache<AnyObject, UIImage>()
        testQueue =  OperationQueue()
        testLoader = ImageLoader(cache: testCache, queue: testQueue, session: URLSession.shared)
        testQueue.isSuspended = true // This prevents ops being completed
        super.setUp()
    }
    
    override func tearDown() {
        testCache.removeAllObjects()
        testQueue.operations.forEach({ $0.cancel() })
        
        super.tearDown()
    }
    
    func testDuplicates() {
        let firstTestResource = URL(string: "http://image.com/1.jpg")!
        let secondTestResource = URL(string: "http://image.com/2.jpg")!
        
        testLoader.request(resource: firstTestResource, completion: nil)
        testLoader.request(resource: firstTestResource, completion: nil)
        
        XCTAssert(testQueue.operations.count == 1)
        
        testLoader.request(resource: secondTestResource, completion: nil)
        
        XCTAssert(testQueue.operations.count == 2)
    }
    
    func testCacheControl() {
        let potentialImageURL = Bundle(for: ImageLoaderTests.self).url(forResource: "thumb", withExtension: "jpg")
        
        guard let imageURL = potentialImageURL,
            let imageData = try? Data(contentsOf: imageURL),
            let image = UIImage(data: imageData) else {
            XCTFail("Couldnt load test image data")
            return
        }
        let firstTestResource = URL(string: "http://image.com/1.jpg")!

        testCache.setObject(image, forKey: firstTestResource.identifier as AnyObject)
        
        let expect = XCTestExpectation(description: "Awaiting Image")
        expect.expectedFulfillmentCount = 1
        
        testLoader.request(resource: firstTestResource) { (image) in
            XCTAssertNotNil(image)
            expect.fulfill()
        }
    }
    
    func testCancelOperation() {
        let firstTestResource = URL(string: "http://image.com/1.jpg")!
     
        testLoader.request(resource: firstTestResource, completion: nil)
        
        XCTAssert(testQueue.operations.count == 1)
        
        testLoader.cancelRequest(resource: firstTestResource)

        XCTAssert(testQueue.operations.first!.isCancelled)
    }
    
    func testOperationCancelledStillCompletes() {
        let firstTestResource = URL(string: "http://image.com/1.jpg")!
        
        testLoader.request(resource: firstTestResource, completion: nil)
        
        testLoader.cancelRequest(resource: firstTestResource)

        testQueue.isSuspended = false
        
        XCTAssert(testQueue.operations.first!.isCancelled)
    }
    
    func testImageViewExtension() {
        let potentialImageURL = Bundle(for: ImageLoaderTests.self).url(forResource: "thumb", withExtension: "jpg")
        
        guard let imageURL = potentialImageURL,
            let imageData = try? Data(contentsOf: imageURL),
            let image = UIImage(data: imageData) else {
                XCTFail("Couldnt load test image data")
                return
        }
        let firstTestResource = URL(string: "http://image.com/1.jpg")!
        
        testCache.setObject(image, forKey: firstTestResource.identifier as AnyObject)

        let iv = UIImageView()
        testImageView = iv
        
        let expect = XCTestExpectation(description: "Awaiting Image")

        iv.loadImage(resource: firstTestResource, loader: testLoader, completion: {
            XCTAssert(iv.image == image)
            expect.fulfill()
        })
        
        wait(for: [expect], timeout: 1)
    }
}
