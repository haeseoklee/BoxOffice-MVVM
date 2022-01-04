//
//  APIConstants.swift
//  BoostCourse5
//
//  Created by Haeseok Lee on 2021/08/25.
//

import Foundation

enum APIConstants {
    static let baseURL = "https://connect-boxoffice.run.goorm.io/"
    
    static let movieListURL = baseURL + "movies"
    
    static let movieURL = baseURL + "movie"
    
    static let reviewListURL = baseURL + "comments"
    
    static let commentURL = baseURL + "comment"
}

enum RequestError: Int, Error {
    case unknown = -1
    case jsonError = -2
    case invalidArgument = -3
    case badRequest = 400
    case notFound = 404
    case internalServerError = 500
}

enum ImageLoaderError: Error {
    case unknown
    case invalidURL
}
