//  OpenAIService.swift
//  Ask ChatGPT iOS
//  Created by Farial Mahmod on 8/24/23.

import Foundation
import Alamofire
import Combine

class OpenAIService{
    
    // URL provided by OpenAI doc
    let baseUrl = "https://api.openai.com/v1/"
    
    // AnyPublisher is a Publisher implementation to expose/emit values over time
    func sendMesssage(message: String) -> AnyPublisher<OpenAICompletionsResponse, Error> {
        
        // the 'model' and 'max_tokens' are in accordance with OpenAI's doc
        let body = OpenAICompletionsBody(model: "text-davinci-003", prompt: message, temperature: 0.75, max_tokens: 255)
        
        // Authorization Header
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(Constants.openAIAPIKey)"
        ]
        
        // returning a Future value with weak reference or else nothing with guard keyword
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            // POST API request using Alamofire
            AF.request(self.baseUrl + "completions", method: .post, parameters: body, encoder: .json, headers: headers)
                    .responseDecodable(of: OpenAICompletionsResponse.self){ response in
                        
                        // printing the response in debug mode
                        debugPrint(response.debugDescription)
                        
                        // the response can either be a success or a failure
                        switch response.result {
                        case .success(let result):
                            promise(.success(result))
                            
                        case .failure(let error):
                            promise(.failure(error))
                        }
            }
            // 'eraseToAnyPublisher()' to expose an instance of AnyPublisher to the subscriber
        }.eraseToAnyPublisher()
    }
}
    
// the properties are required as per the OpenAI's type format
    struct OpenAICompletionsBody: Encodable {
        let model: String
        let prompt: String
        let temperature: Float?
        let max_tokens: Int
    }
    
    struct OpenAICompletionsResponse: Decodable {
        let id: String
        let choices: [OpenAICompletionsChoices]
    }
    
    struct OpenAICompletionsChoices: Decodable{
        let text: String
    }


