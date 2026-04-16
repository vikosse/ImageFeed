//
//  ImagesListPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Alekhina Viktoriya on 15/04/2026.
//

import Foundation
@testable import ImageFeed

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    var photos: [Photo] = []
    var viewDidLoadCalled = false
    var fetchNextPageCalled = false
    var changeLikeCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func fetchNextPage() {
        fetchNextPageCalled = true
    }

    func changeLike(
        photoId: String,
        isLiked: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        changeLikeCalled = true
        completion(.success(()))
    }
}
