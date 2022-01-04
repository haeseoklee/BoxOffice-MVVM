//
//  CommentRequest.swift
//  BoostCourse5
//
//  Created by Haeseok Lee on 2021/08/25.
//

import Foundation
import RxSwift

struct CommentRequest {
    static let shared = CommentRequest()
    
    func getCommentListRx(movieId: String) -> Observable<CommentList> {
        return Observable.create { observer in
            DispatchQueue.global().async {
                sendGetCommentListRequest(movieId: movieId) { result in
                    switch result {
                    case .success(let comments):
                        observer.onNext(comments)
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    func postCommentRx(comment: Comment) -> Observable<Comment> {
        return Observable.create { observer in
            DispatchQueue.global().async {
                sendPostCommentRequest(comment: comment) { result in
                    switch result {
                    case .success(let comment):
                        observer.onNext(comment)
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    func sendGetCommentListRequest(movieId: String, completion: @escaping (Result<CommentList, RequestError>) -> Void) {
        var components = URLComponents(string: APIConstants.reviewListURL)
        let items: [URLQueryItem] = [
            URLQueryItem(name: "movie_id", value: "\(movieId)")
        ]
        
        components?.queryItems = items
        
        if let url = components?.url {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        do {
                            let json = try JSONDecoder().decode(CommentList.self, from: data)
                            completion(.success(json))
                        } catch {
                            completion(.failure(.jsonError))
                        }
                    } else {
                        let commentRequestError = RequestError(rawValue: response.statusCode) ?? .unknown
                        completion(.failure(commentRequestError))
                    }
                } else {
                    completion(.failure(.unknown))
                }
            }
            task.resume()
        }
    }
    
    func sendPostCommentRequest(comment: Comment, completion: @escaping (Result<Comment, RequestError>) -> Void) {
        guard let url = URL(string: APIConstants.commentURL) else {
            completion(.failure(.invalidArgument))
            return
        }
        
        var json: [String: Any] = [:]
        json["rating"] = comment.rating
        json["writer"] = comment.writer
        json["movie_id"] = comment.movieId
        json["contents"] = comment.contents
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = data
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data, let response = response as? HTTPURLResponse {
                    if response.statusCode == 201 {
                        do {
                            let data = try JSONDecoder().decode(Comment.self, from: data)
                            completion(.success(data))
                        } catch {
                            completion(.failure(.jsonError))
                        }
                    } else {
                        let commentRequestError = RequestError(rawValue: response.statusCode) ?? .unknown
                        completion(.failure(commentRequestError))
                    }
                }
            }
            task.resume()
        } catch {
            completion(.failure(.jsonError))
        }
    }
}
