//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Dmitriy Tarasov on 28.05.2024.
//

import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(previousRecord: GameResult) -> Bool {
        if self.correct > previousRecord.correct {
            return true
        }
        return false
    }
}
