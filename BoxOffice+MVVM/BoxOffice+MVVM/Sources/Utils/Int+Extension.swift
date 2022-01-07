//
//  Int+Extension.swift
//  BoxOffice+MVVM
//
//  Created by Haeseok Lee on 2022/01/05.
//

import Foundation

extension Int {
    
    func intWithCommas() -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: self))
    }
}
