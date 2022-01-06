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
        let reservationRateAction = UIAlertAction(
            title: "예매율",
            style: .default,
            handler: reservationRateAction
        )
        let curationAction = UIAlertAction(
            title: "큐레이션",
            style: .default,
            handler: curationAction
        )
        let openingDateAction = UIAlertAction(
            title: "개봉일",
            style: .default,
            handler: openingDateAction
        )
        let cancel = UIAlertAction(
            title: "취소",
            style: .cancel,
            handler : nil
        )
        alert.addAction(reservationRateAction)
        alert.addAction(curationAction)
        alert.addAction(openingDateAction)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
}
