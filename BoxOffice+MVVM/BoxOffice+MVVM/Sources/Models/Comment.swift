//
//  Comment.swift
//  BoostCourse5
//
//  Created by Haeseok Lee on 2021/08/25.
//

import Foundation

struct Comment: Codable {
    let id: String?
    let rating: Double
    let timestamp: Double?
    let writer: String
    let movieId: String
    let contents: String
    
    enum CodingKeys: String, CodingKey {
        case id, rating, timestamp, writer, contents
        case movieId = "movie_id"
    }
}
