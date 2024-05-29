import UIKit


// контроллер
final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, UserCommandDelegate {
    
    // свойства для генерации вопросов
    private let questionsAmount = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    // индекс текущего вопроса
    private var currentQuestionIndex = 0
    
    // счетчик правильных ответов
    private var correctAnswers = 0
    
    //
    private var statisticService: StatisticServiceProtocol?
    
    // аутлеты для изменяемых элементов экрана
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // создаем фабрику вопросов и указываем делегата
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        
        // создаем сервис статистики
        statisticService = StatisticService()
        
        // запрашиваем первый вопрос
        questionFactory.requestNextQuestion()
    }
    
    // конвертор mock-данных в ViewModel
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex+1)/\(questionsAmount)"
        )
    }
    
    // метод, который заполняет экран данными, принимая view model
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderWidth = 0
    }
    
    
    // метод, который меняет цвет рамки в зависимости от правильности ответа
    private func showAnswerResult(isCorrect: Bool){
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        if isCorrect {
            correctAnswers += 1
        }
        
        // через 1 секунду запускаем следующий вопрос, либо показываем результаты
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    // переход в следующий вопрос либо показ результатов
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount {
            // тест пройдет, сохраняем статистику и формируем сообщение для алерта
            var alertText = ""
            
            if let statisticService = statisticService {
                // сохраняем статистику
                statisticService.store(correct: correctAnswers, total: questionsAmount)
                // формируем текст для алерта
                alertText = "Ваш результат: \(correctAnswers)/\(questionsAmount)\nКоличество сыгранных квизов: \(statisticService.gamesCount)\nРекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))\nСредняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            } else {
                // альтернативный текст для алерта, если сервис статистики не создался
                alertText = correctAnswers == questionsAmount ? "Поздравляем, вы ответили на 10 из 10!" : "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
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
            alertPresenter.delegate = self
            alertPresenter.showAlert()
        } else {
            // показываем следующий вопрос
            guard let questionFactory = questionFactory else { return }
            questionFactory.requestNextQuestion()
        }
    }
    
    // обработка нажатия кнопок
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        // определяем правильно ответил пользователь или нет
        guard let currentQuestion = currentQuestion else { return }
        let isCorrectAnswer = currentQuestion.correctAnswer == false
        // показываем пользователю правильность через рамку
        showAnswerResult(isCorrect: isCorrectAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        // определяем правильно ответил пользователь или нет
        guard let currentQuestion = currentQuestion else { return }
        let isCorrectAnswer = currentQuestion.correctAnswer == true
        // показываем пользователю правильность через рамку
        showAnswerResult(isCorrect: isCorrectAnswer)
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {return}
        
        currentQuestion = question
        let viewModel = convert(model: question)
        currentQuestionIndex += 1
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - UserCommandDelegate
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        guard let questionFactory = self.questionFactory else {return}
        questionFactory.requestNextQuestion()
    }
}
