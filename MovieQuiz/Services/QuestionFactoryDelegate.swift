//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Dmitriy Tarasov on 28.05.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
