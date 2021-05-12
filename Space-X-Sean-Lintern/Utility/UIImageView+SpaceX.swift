import UIKit

extension UIImageView {
    func loadImage(resource: URL, loader: ImageLoader = ImageLoader.shared, completion: (() -> Void)? = nil) {
        loader.request(resource: resource) { [weak self] (image) in
            self?.image = image
            completion?()
        }
    }
}
