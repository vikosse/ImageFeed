//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 06/04/2026.
//

import Foundation

final class ImagesListService {

    // MARK: - Static properties

    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(
        rawValue: "ImagesListServiceDidChange"
    )

    // MARK: - Public properties

    private(set) var photos: [Photo] = []

    // MARK: - Private properties

    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private let tokenStorage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared

    // MARK: - Initializers

    private init() {}

    // MARK: - Public methods

    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        guard task == nil else { return }

        let nextPage = (lastLoadedPage ?? 0) + 1

        guard let request = makePhotosRequest(page: nextPage) else {
            return
        }

        task = urlSession.objectTask(for: request) { [weak self] (
            result: Result<[PhotoResult], Error>
        ) in
            guard let self else { return }
            self.handleFetchPhotosNextPage(
                result: result,
                nextPage: nextPage
            )
        }

        task?.resume()
    }

    func changeLike(
        photoId: String,
        isLike: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let token = tokenStorage.token else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        var urlComponents = URLComponents()
        urlComponents.scheme = APIConstants.defaultScheme
        urlComponents.host = APIConstants.unsplashAPIHost
        urlComponents.path = APIConstants.photoLikePath(photoId: photoId)

        guard let url = urlComponents.url else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = isLike ? HTTPMethod.post.rawValue : HTTPMethod.delete.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = urlSession.data(for: request) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success:
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]

                    let updatedPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        description: photo.description,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: isLike
                    )

                    self.photos[index] = updatedPhoto
                }

                completion(.success(()))

            case .failure(let error):
                completion(.failure(error))
            }
        }

        task.resume()
    }

    func resetPhotos() {
        photos = []
        lastLoadedPage = nil
        task?.cancel()
        task = nil
    }

    // MARK: - Private methods

    private func makePhotosRequest(page: Int) -> URLRequest? {
        guard let token = tokenStorage.token else {
            return nil
        }

        var urlComponents = URLComponents()
        urlComponents.scheme = APIConstants.defaultScheme
        urlComponents.host = APIConstants.unsplashAPIHost
        urlComponents.path = APIConstants.photosPath
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: String(page))
        ]

        guard let url = urlComponents.url else {
            print("[ImagesListService.makePhotosRequest]: invalid URL")
            return nil
        }

        return .authorizedRequest(url: url, method: .get, token: token)
    }

    private func handleFetchPhotosNextPage(
        result: Result<[PhotoResult], Error>,
        nextPage: Int
    ) {
        switch result {
        case .success(let photoResults):
            let newPhotos = photoResults.map { $0.photo }
            photos.append(contentsOf: newPhotos)
            lastLoadedPage = nextPage
            NotificationCenter.default.post(
                name: ImagesListService.didChangeNotification,
                object: self
            )
            task = nil

        case .failure(let error):
            print(
                "[ImagesListService.fetchPhotosNextPage]: \(error.localizedDescription)"
            )
            task = nil
        }
    }
}
