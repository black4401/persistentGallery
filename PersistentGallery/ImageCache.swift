//
//  ImageCache.swift
//  PersistentGallery
//
//  Created by Alexander Angelov on 13.01.23.
//

import UIKit

struct CacheCapacity {
    static let memory = 6 * 1024 * 1024
    static let disk = 40 * 1024 * 1024
}

class ImageCache {
    static let shared = ImageCache()
    
    private let cache = URLCache(memoryCapacity: CacheCapacity.memory, diskCapacity: CacheCapacity.disk)
    
    func saveImage(request: URLRequest) {
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, _ in
            if let data = data, let response = response {
                let cachedData = CachedURLResponse(response: response, data: data)
                self.cache.storeCachedResponse(cachedData, for: request)
            }
        }
        dataTask.resume()
    }
    
    func loadOrCacheImage(from imageURL: URL, _ completion: @escaping (UIImage?, URL) -> ()) {
        let request = URLRequest(url: imageURL)
        var image: UIImage?
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let data = self?.cache.cachedResponse(for: request)?.data {
                image = UIImage(data: data)
            } else if let data = try? Data(contentsOf: imageURL) {
                image = UIImage(data: data)
                self?.saveImage(request: request)
            }
            DispatchQueue.main.async {
                completion(image, imageURL)
            }
        }
    }
}
