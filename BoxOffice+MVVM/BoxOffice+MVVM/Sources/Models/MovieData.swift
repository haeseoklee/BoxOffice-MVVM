//
//  MovieData.swift
//  BoostCourse5
//
//  Created by Haeseok Lee on 2021/08/30.
//

import Foundation

enum MovieOrderType: Int {
    case reservationRate = 0, curation = 1, openingDate = 2
    func toKorean() -> String {
        switch self {
        case .reservationRate:
            return "예매율순"
        case .curation:
            return "큐레이션"
        case .openingDate:
            return "개봉일순"
        }
    }
}

class MovieData {
    static let shared: MovieData = MovieData()
    var movieList: [Movie] = []
    var orderType: MovieOrderType = .reservationRate
    
    private init() {}
}
