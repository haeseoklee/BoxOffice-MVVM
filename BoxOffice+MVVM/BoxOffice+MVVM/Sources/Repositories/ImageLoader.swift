//
//  ImageLoader.swift
//  BoostCourse5
//
//  Created by Haeseok Lee on 2021/08/26.
//

import UIKit
import RxSwift

struct ImageLoader {
    let url: String
    
    func loadRx() -> Observable<UIImage> {
        return Observable.create { observer in
            DispatchQueue.global().async {
                load { result in
                    switch result {
                    case .success(let image):
                        observer.onNext(image)
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    func load(completion: @escaping (Result<UIImage, ImageLoaderError>) -> Void) {
        if let url = URL(string: self.url) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let response = response as? HTTPURLResponse, response.statusCode == 200, error == nil, let data = data, let image = UIImage(data: data) else {
                    completion(.failure(.unknown))
                    return
                }
                completion(.success(image))
            }
            task.resume()
        } else {
            completion(.failure(.invalidURL))
        }
    }
}
