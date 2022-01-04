//
//  Movie.swift
//  BoostCourse5
//
//  Created by Haeseok Lee on 2021/08/25.
//

import Foundation

struct MovieList: Codable {
    let orderType: Int
    let movies: [Movie]

    enum CodingKeys: String, CodingKey {
        case orderType = "order_type"
        case movies
    }
}
