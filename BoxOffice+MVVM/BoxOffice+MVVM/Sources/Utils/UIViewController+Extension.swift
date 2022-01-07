//
//  UIViewController+Extension.swift
//  BoostCourse5
//
//  Created by Haeseok Lee on 2021/12/27.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "확인", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func showActionSheet(
        reservationRateAction: ((UIAlertAction) -> Void)?,
        curationAction: ((UIAlertAction) -> Void)?,
        openingDateAction: ((UIAlertAction) -> Void)?
    ) {
        let alert = UIAlertController(
            title: "정렬방식 선택",
            message: "영화를 어떤 순서로 정렬할까요?",
            preferredStyle: UIAlertController.Style.actionSheet
        )
        MovieOrderType.allCases.forEach { type in
            var handler: ((UIAlertAction) -> Void)?
            switch type {
            case .reservationRate:
                handler = reservationRateAction
            case .curation:
                handler = curationAction
            case .openingDate:
                handler = openingDateAction
            }
            let action = UIAlertAction(title: type.toKorean(), style: .default, handler: handler)
            alert.addAction(action)
        }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler : nil))
        present(alert, animated: true, completion: nil)
    }
}
