import UIKit


// контроллер
final class MovieQuizViewController: UIViewController,
                                     UserCommandDelegate,
                                     MovieQuizViewControllerProtocol {
    
    // презентер
    private var presenter: MovieQuizPresenter!
    
    // аутлеты для изменяемых элементов экрана
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var activityIndecator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // передаем контроллер презентеру
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    // Обработка нажатий кнопок
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
            presenter.yesButtonClicked()
        }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
            presenter.noButtonClicked()
        }
    
    // метод, который заполняет экран данными, принимая view model
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderWidth = 0
    }
    
    // метод, который меняет цвет рамки в зависимости от правильности ответа
    func highlightImageBorder(isCorrectAnswer: Bool) {
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        }
    
    // показ индикатора загрузки
    func showLoadingIndicator() {
        activityIndecator.isHidden = false
        activityIndecator.startAnimating()
    }
    
    // скрытие интикатора загрузки
    func hideLoadingIndicator() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndecator.isHidden = true
            self?.activityIndecator.stopAnimating()
        }
    }
    
    // MARK: - UserCommandDelegate
    func restartGame() {
        presenter.restartGame()
    }
    
    func showNetworkError(message: String){
        hideLoadingIndicator()
        
        // готовим модель для диалога ошибки
        let alertModel = AlertModel(
            title: "Ошибка загрузки",
            message: message,
            buttonText: "Попробовать еще раз",
            completion: presenter.restartGame
        )
        
        // создаем Alert Presenter и указываем делегата
        let alertPresenter = AlertPresenter(alertContents: alertModel)
        alertPresenter.delegate = self
        alertPresenter.showAlert()
    }
}
