//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Dmitriy Tarasov on 28.05.2024.
//

import Foundation

// enum для ключей
private enum Keys: String {
    case totalCorrectAnswers
    case bestGameCorrectAnswers
    case bestGameTotalQuestions
    case bestGameDate
    case gamesCount
}


final class StatisticService: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard
    
    // общее количество игр
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    // общее количество правильных ответов
    var correctAnswers: Int {
        get {
            storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue)
        }
    }
    
    // результат конкретной игры
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrectAnswers.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotalQuestions.rawValue)
            var date = Date()
            
            if let storedDate = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date {
                date = storedDate
            }
            
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrectAnswers.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotalQuestions.rawValue)
            storage.set(Date(), forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get {
            return (Double(correctAnswers)/(10.0 * Double(gamesCount))) * 100.0
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        // сперва обновляем общее количество игр и общее количество правильных ответов
        gamesCount += 1
        correctAnswers += count
        
        // теперь сравниваем текущую игру с лучшей и обновляем ее, если побили рекорд
        let currentGameResult = GameResult(correct: count, total: amount, date: Date())
        if currentGameResult.isBetterThan(previousRecord: bestGame) {
            bestGame = currentGameResult
        }
    }
    
    
}
