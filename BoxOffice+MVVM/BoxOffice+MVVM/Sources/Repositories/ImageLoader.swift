//
//  ImageLoader.swift
//  BoostCourse5
//
//  Created by Haeseok Lee on 2021/08/26.
//

import UIKit
import RxSwift

class ImageCacheManager {
    static let shared: NSCache<NSString, UIImage>  = NSCache<NSString, UIImage>()
}

struct ImageLoader {
    let url: String
    
    func loadRx() -> Observable<UIImage> {
        return Observable.create { observer in
            load { result in
                switch result {
                case .success(let image):
                    observer.onNext(image)
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    private func load(completion: @escaping (Result<UIImage, ImageLoaderError>) -> Void) {
        
        let imageKey = url as NSString
        if let cachedImage = ImageCacheManager.shared.object(forKey: imageKey) {
            completion(.success(cachedImage))
            return
        }
        
        if let url = URL(string: self.url) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let response = response as? HTTPURLResponse, response.statusCode == 200, error == nil, let data = data, let image = UIImage(data: data) else {
                    if let error = error as? ImageLoaderError {
                        completion(.failure(error))
                    }
                    return
                }
                ImageCacheManager.shared.setObject(image, forKey: imageKey)
                completion(.success(image))
            }
            task.resume()
        } else {
            completion(.failure(.invalidURL))
        }
    }
}
