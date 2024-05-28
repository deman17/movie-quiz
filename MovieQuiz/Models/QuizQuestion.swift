//
//  QuizQuestion.swift
//  MovieQuiz
//
//  Created by Dmitriy Tarasov on 28.05.2024.
//

import Foundation

// структура для вопроса квиза
struct QuizQuestion {
    // строка с названием фильма (имя файла картинки в Assets)
    let image: String
    // строка с вопросом о рейтинге фильма
    let text: String
    // булевое значение (да/нет) - ответ на вопрос
    let correctAnswer: Bool
}
