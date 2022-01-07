//
//  Movie.swift
//  BoostCourse5
//
//  Created by Haeseok Lee on 2021/08/25.
//

import Foundation

enum MovieOrderType: Int, CaseIterable {
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

struct Movie: Codable {
    let audience: Int?
    let actor: String?
    let duration: Int?
    let director: String?
    let thumb: String?
    let image: String?
    let synopsis: String?
    let genre: String?
    let grade: Int
    let reservationGrade: Int
    let title: String
    let reservationRate: Double
    let userRating: Double
    let date: String
    let id: String
    var gradeImageName: String {
        if grade == 0 {
            return "ic_allages"
        } else {
            return "ic_\(grade)"
        }
    }
    static let empty: Movie = Movie(audience: nil, actor: nil, duration: nil, director: nil, thumb: nil, image: nil, synopsis: nil, genre: nil, grade: 0, reservationGrade: 0, title: "", reservationRate: 0, userRating: 0, date: "", id: "")
    
    enum CodingKeys: String, CodingKey {
        case audience, actor, director, duration, thumb, image
        case synopsis, genre, grade, title, date, id
        case reservationGrade = "reservation_grade"
        case reservationRate = "reservation_rate"
        case userRating = "user_rating"
    }
}
