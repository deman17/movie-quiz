//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Dmitriy Tarasov on 29.05.2024.
//

import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    // тест на успешное взятие элемента по индексу
    func testGetValueInRange() throws {
        // Given
        let array = [1, 2, 3, 4, 5]
        
        // When
        let value = array[safe: 2]
        
        // Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 3)
    }
    
    // тест на nil при неправильном индексе
    func testGetValueOutOfRange() throws {
        // Given
        let array = [1, 2, 3, 4, 5]
        
        // When
        let value = array[safe: 5]
        
        // Then
        XCTAssertNil(value)
    }
}
