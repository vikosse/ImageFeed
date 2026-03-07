//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 07/03/2026.
//
import Foundation

final class OAuth2Service {
    
    // MARK: - Shared instance
    static let shared = OAuth2Service()
    
    // MARK: - Private properties
    private let urlSession = URLSession.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    
    private init() {}
    
    // MARK: - Private methods
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "unsplash.com"
        urlComponents.path = "/oauth/token"
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    // MARK: - Public methods
    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = urlSession.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let responseBody = try JSONDecoder().decode(
                        OAuthTokenResponseBody.self,
                        from: data
                    )
                    
                    let accessToken = responseBody.accessToken
                    self.tokenStorage.token = accessToken
                    completion(.success(accessToken))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(NetworkError.decodingError(error)))
                }
                
            case .failure(let error):
                print("OAuth token request error: \(error)")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
