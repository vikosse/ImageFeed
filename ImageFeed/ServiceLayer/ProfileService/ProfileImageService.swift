//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 25/03/2026.
//
import Foundation

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(
        rawValue: "ProfileImageProviderDidChange"
    )
    
    // MARK: - Private properties
    private let urlSession = URLSession.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    
    private var task: URLSessionTask?
    private var lastUsername: String?
    
    private(set) var avatarURL: String?
    
    private init() {}
    
    // MARK: - Public methods
    func fetchProfileImageURL(
        username: String,
        _ completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        
        guard lastUsername != username else {
            print(
                "[ProfileImageService.fetchProfileImageURL]: invalidRequest - repeated username: \(username)"
            )
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        task?.cancel()
        
        guard
            let token = tokenStorage.token,
            let request = makeProfileImageRequest(
                username: username,
                token: token
            )
        else {
            print(
                "[ProfileImageService.fetchProfileImageURL]: invalidRequest - username: \(username)"
            )
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        lastUsername = username
        
        let task = urlSession.objectTask(for: request) { [weak self]
            (result: Result<UserResult,Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let userResult):
                let avatarURL = userResult.profileImage.small
                self.avatarURL = avatarURL
                
                completion(.success(avatarURL))
                
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": avatarURL]
                )
                
            case .failure(let error):
                print(
                    "[ProfileImageService.fetchProfileImageURL]: failure - username: \(username), error: \(error.localizedDescription)"
                )
                completion(.failure(error))
            }
            
            self.task = nil
            self.lastUsername = nil
        }
        
        self.task = task
        task.resume()
    }
    
    // MARK: - Private methods
    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = APIConstants.defaultScheme
        urlComponents.host = APIConstants.unsplashAPIHost
        urlComponents.path = APIConstants.userProfilePath(username: username)
        
        guard let url = urlComponents.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
