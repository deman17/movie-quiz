//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Dmitriy Tarasov on 28.05.2024.
//

import UIKit

final class AlertPresenter {
    // модель с данными алерта
    let alertContents: AlertModel
    weak var delegate: UserCommandDelegate?
    
    // инициализатор
    init(alertContents: AlertModel) {
        self.alertContents = alertContents
    }
    
    // метод показа алерта
    func showAlert() {
        
        let alert = UIAlertController(
            title: alertContents.title,
            message: alertContents.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(
            title: alertContents.buttonText,
            style: .default
        ) {_ in
            self.alertContents.completion()
        }
        
        alert.addAction(action)
        delegate?.present(alert, animated: true, completion: nil)
    }
}
