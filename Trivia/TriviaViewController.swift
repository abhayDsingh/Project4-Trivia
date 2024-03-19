//
//  ViewController.swift
//  Trivia
//
//  Created by Mari Batilando on 4/6/23.
//

import UIKit

class TriviaViewController: UIViewController {
    private let triviaService = TriviaQuestionService()

  
  @IBOutlet weak var currentQuestionNumberLabel: UILabel!
  @IBOutlet weak var questionContainerView: UIView!
  @IBOutlet weak var questionLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var answerButton0: UIButton!
  @IBOutlet weak var answerButton1: UIButton!
  @IBOutlet weak var answerButton2: UIButton!
  @IBOutlet weak var answerButton3: UIButton!
  
    @IBOutlet weak var resetButton: UIButton!
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        resetGame()
    }

    
    
    private var questions = [TriviaQuestion]()
  private var currQuestionIndex = 0
  private var numCorrectQuestions = 0
  
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradient()
        questionContainerView.layer.cornerRadius = 8.0
        
        triviaService.fetchSessionToken { [weak self] result in
            switch result {
            case .success(let token):
                print("Session Token: \(token)")
                self?.fetchQuestions()
            case .failure(let error):
                print("Error fetching session token: \(error)")
            }
        }
    }
    
    func fetchQuestions() {
        triviaService.fetchTriviaQuestions { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let questions):
                    self?.questions = questions
                    self?.updateQuestion(withQuestionIndex: 0)
                case .failure(let error):
                    print("Error fetching questions: \(error)")
                }
            }
        }
    }
    
    private func resetGame() {
        currQuestionIndex = 0 // Reset the current question index
        numCorrectQuestions = 0 // Reset the score
        triviaService.resetSessionToken { [weak self] result in
            DispatchQueue.main.async { // Ensure UI updates are on the main thread
                switch result {
                case .success:
                    self?.fetchQuestions()
                case .failure(let error):
                    print("Error resetting session token: \(error)")
                }
            }
        }
    }
  
    private func updateQuestion(withQuestionIndex questionIndex: Int) {
        guard questionIndex < questions.count else { return }
        
        currentQuestionNumberLabel.text = "Question: \(questionIndex + 1)/\(questions.count)"
        
        let question = questions[questionIndex]
        
        // Decode the URL-encoded question string
        let decodedQuestion = question.question.removingPercentEncoding ?? "Invalid question format"
        questionLabel.text = decodedQuestion
        
        // Decode the URL-encoded category string
        let decodedCategory = question.category.removingPercentEncoding ?? "Invalid category format"
        categoryLabel.text = decodedCategory
        
        let answers = ([question.correctAnswer] + question.incorrectAnswers).shuffled().compactMap { $0.removingPercentEncoding }
        
        // Assign the decoded answers to the buttons, hide if there are less than 4 answers
        answerButton0.setTitle(answers.count > 0 ? answers[0] : "", for: .normal)
        answerButton0.isHidden = answers.count < 1
        
        answerButton1.setTitle(answers.count > 1 ? answers[1] : "", for: .normal)
        answerButton1.isHidden = answers.count < 2
        
        answerButton2.setTitle(answers.count > 2 ? answers[2] : "", for: .normal)
        answerButton2.isHidden = answers.count < 3
        
        answerButton3.setTitle(answers.count > 3 ? answers[3] : "", for: .normal)
        answerButton3.isHidden = answers.count < 4
    }

  
  private func updateToNextQuestion(answer: String) {
    if isCorrectAnswer(answer) {
      numCorrectQuestions += 1
    }
    currQuestionIndex += 1
    guard currQuestionIndex < questions.count else {
      showFinalScore()
      return
    }
    updateQuestion(withQuestionIndex: currQuestionIndex)
  }
  
  private func isCorrectAnswer(_ answer: String) -> Bool {
    return answer == questions[currQuestionIndex].correctAnswer
  }
  
  private func showFinalScore() {
    let alertController = UIAlertController(title: "Game over!",
                                            message: "Final score: \(numCorrectQuestions)/\(questions.count)",
                                            preferredStyle: .alert)
      let resetAction = UIAlertAction(title: "Restart", style: .default) { [unowned self] _ in
        self.resetGame()
      }
    alertController.addAction(resetAction)
    present(alertController, animated: true, completion: nil)
  }
  
  private func addGradient() {
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = view.bounds
    gradientLayer.colors = [UIColor(red: 0.54, green: 0.88, blue: 0.99, alpha: 1.00).cgColor,
                            UIColor(red: 0.51, green: 0.81, blue: 0.97, alpha: 1.00).cgColor]
    gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
    gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    view.layer.insertSublayer(gradientLayer, at: 0)
  }
  
  @IBAction func didTapAnswerButton0(_ sender: UIButton) {
    updateToNextQuestion(answer: sender.titleLabel?.text ?? "")
  }
  
  @IBAction func didTapAnswerButton1(_ sender: UIButton) {
    updateToNextQuestion(answer: sender.titleLabel?.text ?? "")
  }
  
  @IBAction func didTapAnswerButton2(_ sender: UIButton) {
    updateToNextQuestion(answer: sender.titleLabel?.text ?? "")
  }
  
  @IBAction func didTapAnswerButton3(_ sender: UIButton) {
    updateToNextQuestion(answer: sender.titleLabel?.text ?? "")
  }
}

