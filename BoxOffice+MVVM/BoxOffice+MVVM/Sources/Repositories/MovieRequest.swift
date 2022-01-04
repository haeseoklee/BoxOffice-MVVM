//
//  MovieRequest.swift
//  BoostCourse5
//
//  Created by Haeseok Lee on 2021/08/25.
//

import Foundation

enum MovieRequestError: Int, Error {
    case unknown = -1
    case jsonError = -2
    case invalidArgument = -3
    case badRequest = 400
    case notFound = 404
    case internalServerError = 500
}


struct MovieRequest {
    static let shared = MovieRequest()
    
    func sendGetMovieListRequest(orderType: Int, completion: @escaping (Result<MovieList, MovieRequestError>) -> Void) {
        var components = URLComponents(string: APIConstants.movieListURL)
        let items: [URLQueryItem] = [
            URLQueryItem(name: "order_type", value: "\(orderType)")
        ]
        
        if !((0...2) ~= orderType) {
            completion(.failure(.invalidArgument))
        }
        
        components?.queryItems = items
        
        if let url = components?.url {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        do {
                            let json = try JSONDecoder().decode(MovieList.self, from: data)
                            completion(.success(json))
                        } catch {
                            completion(.failure(.jsonError))
                        }
                    } else {
                        let movieRequestError = MovieRequestError(rawValue: response.statusCode) ?? .unknown
                        completion(.failure(movieRequestError))
                    }
                } else {
                    completion(.failure(.unknown))
                }
            }
            task.resume()
        }
    }
    
    func sendGetMovieRequest(id: String, completion: @escaping (Result<Movie, MovieRequestError>) -> Void) {
        var components = URLComponents(string: APIConstants.movieURL)
        let items: [URLQueryItem] = [
            URLQueryItem(name: "id", value: "\(id)")
        ]
        
        components?.queryItems = items
        
        if let url = components?.url {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        do {
                            let json = try JSONDecoder().decode(Movie.self, from: data)
                            completion(.success(json))
                        } catch {
                            completion(.failure(.jsonError))
                        }
                    } else {
                        let movieRequestError = MovieRequestError(rawValue: response.statusCode) ?? .unknown
                        completion(.failure(movieRequestError))
                    }
                } else {
                    completion(.failure(.unknown))
                }
            }
            task.resume()
        }
    }
}
