import Foundation

class TriviaQuestionService {
    private var sessionToken: String?

    func fetchSessionToken(completion: @escaping (Result<String, Error>) -> Void) {
        let tokenURL = URL(string: "https://opentdb.com/api_token.php?command=request")!

        let task = URLSession.shared.dataTask(with: tokenURL) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                self.sessionToken = tokenResponse.token
                completion(.success(tokenResponse.token))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func fetchTriviaQuestions(amount: Int = 5, completion: @escaping (Result<[TriviaQuestion], Error>) -> Void) {
        guard let sessionToken = sessionToken else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
            return
        }
        
        let triviaURL = URL(string: "https://opentdb.com/api.php?amount=\(amount)&token=\(sessionToken)&type=multiple&encode=url3986")!
        
        let task = URLSession.shared.dataTask(with: triviaURL) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let triviaResponse = try JSONDecoder().decode(TriviaResponse.self, from: data)
                let questions = triviaResponse.results.map { result in
                    TriviaQuestion(category: result.category,
                                   question: result.question,
                                   correctAnswer: result.correct_answer,
                                   incorrectAnswers: result.incorrect_answers)
                }
                completion(.success(questions))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func resetSessionToken(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let sessionToken = sessionToken else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
            return
        }
        
        let resetURL = URL(string: "https://opentdb.com/api_token.php?command=reset&token=\(sessionToken)")!
        
        let task = URLSession.shared.dataTask(with: resetURL) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(()))
        }
        task.resume()
    }
}

// Token Response for decoding the token JSON
struct TokenResponse: Codable {
    let response_code: Int
    let response_message: String
    let token: String
}

// Trivia Response for decoding the trivia questions JSON
struct TriviaResponse: Codable {
    let response_code: Int
    let results: [TriviaResult]
}

// Trivia Result for decoding each trivia question JSON
struct TriviaResult: Codable {
    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}
