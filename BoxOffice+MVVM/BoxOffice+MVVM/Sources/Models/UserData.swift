//
//  UserData.swift
//  BoostCourse5
//
//  Created by Haeseok Lee on 2021/08/30.
//

import Foundation

class UserData {
    static let shared: UserData = UserData()
    var nickname: String?
    
    private init() {}
}
