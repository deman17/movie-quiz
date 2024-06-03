//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Dmitriy Tarasov on 30.05.2024.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    // количество вопросов в квизе
    private let questionsAmount = 10
    
    // счетчик правильных ответов
    private var correctAnswers = 0
    
    // индекс текущего вопроса
    private var currentQuestionIndex = 0
    
    // модель текущего вопроса
    private var currentQuestion: QuizQuestion?
    
    // свойство для генерации вопросов
    private var questionFactory: QuestionFactoryProtocol?
    
    // сервис для сетевого соединения
    private let networkClient: NetworkClient = NetworkClient()
    
    // сервис показа статистики после игры
    private var statisticService: StatisticServiceProtocol?
    
    // ссылка на контроллер
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        // назначем контроллер
        self.viewController = viewController
        
        // создаем фабрику вопросов и получаем вопросы
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
        
        // создаем сервис статистики
        statisticService = StatisticService()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    // методы обращения к currentQuestionIndex
    func allQuestionsShowed() -> Bool {
        return currentQuestionIndex == questionsAmount
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.loadData()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    // конвертор mock-данных в ViewModel
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex+1)/\(questionsAmount)"
        )
    }
    
    // обработка нажатия кнопок
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let isCorrectAnswer = currentQuestion.correctAnswer == isYes
        if (isCorrectAnswer) { correctAnswers += 1 }
        // показываем пользователю правильность через рамку
        showAnswerResult(isCorrect: isCorrectAnswer)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    // обработка следующего вопроса
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {return}
        
        currentQuestion = question
        let viewModel = convert(model: question)
        switchToNextQuestion()
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    // показ правильности ответа
    func showAnswerResult(isCorrect: Bool) {
            viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                self.showNextQuestionOrResults()
            }
        }
    
    // переход в следующий вопрос либо показ результатов
    func showNextQuestionOrResults() {
        if self.allQuestionsShowed() {
            // тест пройден, сохраняем статистику и формируем сообщение для алерта
            var alertText = ""
            
            if let statisticService = statisticService {
                // сохраняем статистику
                statisticService.store(correct: correctAnswers, total: self.questionsAmount)
                // формируем текст для алерта
                alertText = """
                    Ваш результат: \(correctAnswers)/\(self.questionsAmount)
                    Количество сыгранных квизов: \(statisticService.gamesCount)
                    Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
                    Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                """
            } else {
                // альтернативный текст для алерта, если сервис статистики не создался
                alertText = correctAnswers == self.questionsAmount ? "Поздравляем, вы ответили на 10 из 10!" : "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            }
            
            // готовим модель результатов теста
            let results = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: alertText,
                buttonText: "Сыграть еще раз"
            )
            
            // готовим контент алерта

            let alertModel = AlertModel(
                title: results.title,
                message: results.text,
                buttonText: results.buttonText,
                completion: restartGame
            )
            
            // создаем Alert Presenter и указываем делегата
            let alertPresenter = AlertPresenter(alertContents: alertModel)
            alertPresenter.delegate = viewController as? MovieQuizViewController
            alertPresenter.showAlert()
        } else {
            // показываем следующий вопрос
            guard let questionFactory = questionFactory else { return }
            questionFactory.requestNextQuestion()
        }
    }
    
}
