//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 07/03/2026.
//
import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    
    // MARK: - Shared instance
    static let shared = OAuth2Service()
    
    // MARK: - Private properties
    private let urlSession = URLSession.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private init() {}
    
    // MARK: - Public methods
    func fetchOAuthToken(
        _ code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        task?.cancel()
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        lastCode = code
        
        let task = urlSession.objectTask(for: request) { [weak self]
            (result: Result<OAuthTokenResponseBody,Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let responseBody):
                let accessToken = responseBody.accessToken
                self.tokenStorage.token = accessToken
                completion(.success(accessToken))
                self.task = nil
                self.lastCode = nil
                
            case .failure(let error):
                print(
                    "[OAuth2Service.fetchOAuthToken]: failure - code: \(code), error: \(error.localizedDescription)"
                )
                completion(.failure(error))
                self.task = nil
                self.lastCode = nil
            }
        }
        
        self.task = task
        task.resume()
    }
    
    // MARK: - Private methods
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = APIConstants.defaultScheme
        urlComponents.host = APIConstants.unsplashHost
        urlComponents.path = APIConstants.authPath
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
        request.httpMethod = HTTPMethod.post.rawValue
        return request
    }
}
