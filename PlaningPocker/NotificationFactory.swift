//
//  NotificationFactory.swift
//  PlaningPocker
//
//  Created by Ирина Петрова on 10.08.2021.
//

import Foundation
import UIKit

class NotificationFactory {
    func showErrorNotification(vc: UIViewController, message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: "OK",
            style: .default
        ))

        vc.present(alert, animated: true)
    }
}
