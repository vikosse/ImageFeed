//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 24/03/2026.
//
import Foundation

final class ProfileService {

    static let shared = ProfileService()

    // MARK: - Private properties
    private let urlSession = URLSession.shared

    private var task: URLSessionTask?
    private var lastToken: String?

    private(set) var profile: Profile?

    private init() {}

    // MARK: - Public methods
    func fetchProfile(
        _ token: String,
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        assert(Thread.isMainThread)

        guard lastToken != token else {
            print(
                "[ProfileService.fetchProfile]: invalidRequest - repeated token"
            )
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        task?.cancel()

        guard let request = makeProfileRequest(token: token) else {
            print(
                "[ProfileService.fetchProfile]: invalidRequest - failed to create request"
            )
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        lastToken = token

        let task = urlSession.objectTask(for: request) { [weak self]
            (result: Result<ProfileResult, Error>) in
                guard let self else { return }

                switch result {
                case .success(let profileResult):
                    let profile = Profile(from: profileResult)
                    self.profile = profile
                    completion(.success(profile))

                case .failure(let error):
                    print(
                        "[ProfileService.fetchProfile]: failure - error: \(error.localizedDescription)"
                    )
                    completion(.failure(error))
                }

                self.task = nil
                self.lastToken = nil
        }

        self.task = task
        task.resume()
    }

    // MARK: - Private methods
    private func makeProfileRequest(token: String) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = APIConstants.defaultScheme
        urlComponents.host = APIConstants.unsplashAPIHost
        urlComponents.path = APIConstants.mePath

        guard let url = urlComponents.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }
}
