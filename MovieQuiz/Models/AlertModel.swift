//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Dmitriy Tarasov on 28.05.2024.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> ()
}
