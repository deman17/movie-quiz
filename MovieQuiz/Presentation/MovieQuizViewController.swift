import UIKit

// структура для вопроса к показу на экране
struct QuizQuestion {
    // строка с названием фильма (имя файла картинки в Assets)
    let image: String
    // строка с вопросом о рейтинге фильма
    let text: String
    // булевое значение (да/нет) - ответ на вопрос
    let correctAnswer: Bool
}

// вью-модель состояния "Вопрос показан"
struct QuizStepViewModel {
    // картинка
    let image: UIImage
    // вопрос о рейтинге
    let question: String
    // строка с индикацией номера вопроса
    let questionNumber: String
}

// вью модель состояния "Показ результатов"
struct QuizResultsViewModel {
    // заголовок алерта
    let title: String
    // строка с текстом о количестве очков
    let text: String
    // текст кнопки алерта
    let buttonText: String
}

// контроллер
final class MovieQuizViewController: UIViewController {
    // mock-данные для показа вопросов пользователю
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
    ]
    
    // индекс текущего вопроса
    private var currentQuestionIndex = 0
    
    // счетчик правильных ответов
    private var correctAnswers = 0

    // аутлеты для изменяемых элементов экрана
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    // конвертор mock-данных в ViewModel
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
                image: UIImage(named: model.image) ?? UIImage(),
                question: model.text,
                questionNumber: "\(currentQuestionIndex+1)/\(questions.count)"
            )
    }
    
    // метод, который заполняет экран данными, принимая view model
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderWidth = 0
    }
    
    // метод показа результатов квиза
    private func show(quiz result: QuizResultsViewModel) {
        // показываем результаты
        let alert = UIAlertController(title: result.title, message: result.text, preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) {_ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.show(quiz: self.convert(model: self.questions[self.currentQuestionIndex]))
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    // переход в следующий вопрос либо показ результатов
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            let results = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/\(questions.count)",
                buttonText: "Сыграть еще раз"
            )
            show(quiz: results)
        } else {
            // показываем следующий вопрос
            currentQuestionIndex += 1
            show(quiz: convert(model: questions[currentQuestionIndex]))
        }
    }
    
    // обработка нажатия кнопок
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        // определяем правильно ответил пользователь или нет
        let isCorrectAnswer = questions[currentQuestionIndex].correctAnswer == false
        // показываем пользователю правильность через рамку
        showAnswerResult(isCorrect: isCorrectAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        // определяем правильно ответил пользователь или нет
        let isCorrectAnswer = questions[currentQuestionIndex].correctAnswer == true
        // показываем пользователю правильность через рамку
        showAnswerResult(isCorrect: isCorrectAnswer)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // показываем первый вопрос
        show(quiz: convert(model: self.questions[currentQuestionIndex]))
    }
    
}


/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
*/
