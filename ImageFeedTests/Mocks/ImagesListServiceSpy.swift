//
//  ImagesListServiceSpy.swift
//  ImageFeedTests
//
//  Created by Alekhina Viktoriya on 15/04/2026.
//

import Foundation
@testable import ImageFeed

final class ImagesListServiceSpy: ImagesListServiceProtocol {
    var photos: [Photo] = []
    let didChangeNotification = Notification.Name("ImagesListServiceSpyDidChange")
    var fetchPhotosNextPageCalled = false
    var changeLikeCalled = false
    var changeLikeResult: Result<Void, Error> = .success(())

    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }

    func changeLike(
        photoId: String,
        isLiked: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        changeLikeCalled = true
        completion(changeLikeResult)
    }
}

enum ImagesListServiceSpyError: Error {
    case test
}
