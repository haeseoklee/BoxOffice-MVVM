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
