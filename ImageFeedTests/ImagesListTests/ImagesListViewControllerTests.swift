//
//  ImagesListViewControllerTests.swift
//  ImageFeedTests
//
//  Created by Alekhina Viktoriya on 15/04/2026.
//

import XCTest
@testable import ImageFeed

@MainActor
final class ImagesListViewControllerTests: XCTestCase {

    // MARK: - Тест 1: Контроллер вызывает viewDidLoad презентера

    func testViewControllerCallsViewDidLoad() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: ImagesListViewController.self))
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)

        _ = viewController.view

        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    // MARK: - Тест 2: Презентер запрашивает следующую страницу при viewDidLoad

    func testPresenterCallsFetchPhotosNextPageOnViewDidLoad() {
        let service = ImagesListServiceSpy()
        let presenter = ImagesListPresenter(imagesListService: service)

        presenter.viewDidLoad()

        XCTAssertTrue(service.fetchPhotosNextPageCalled)
    }

    // MARK: - Тест 3: Презентер запрашивает следующую страницу

    func testPresenterCallsFetchPhotosNextPage() {
        let service = ImagesListServiceSpy()
        let presenter = ImagesListPresenter(imagesListService: service)

        presenter.fetchNextPage()

        XCTAssertTrue(service.fetchPhotosNextPageCalled)
    }

    // MARK: - Тест 4: Презентер перезагружает таблицу при первой загрузке фото

    func testPresenterCallsReloadTableViewWhenPhotosLoaded() {
        let viewController = ImagesListViewControllerSpy()
        let service = ImagesListServiceSpy()
        let presenter = ImagesListPresenter(imagesListService: service)
        presenter.view = viewController
        service.photos = [makePhoto(id: "1")]

        presenter.viewDidLoad()
        NotificationCenter.default.post(
            name: service.didChangeNotification,
            object: service
        )
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))

        XCTAssertTrue(viewController.reloadTableViewCalled)
    }

    // MARK: - Тест 5: Презентер добавляет новые ячейки при догрузке фото

    func testPresenterCallsUpdateTableViewAnimatedWhenPhotosAdded() {
        let viewController = ImagesListViewControllerSpy()
        let service = ImagesListServiceSpy()
        let presenter = ImagesListPresenter(imagesListService: service)
        presenter.view = viewController

        service.photos = [makePhoto(id: "1")]
        presenter.viewDidLoad()
        NotificationCenter.default.post(
            name: service.didChangeNotification,
            object: service
        )
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))

        service.photos = [makePhoto(id: "1"), makePhoto(id: "2")]
        NotificationCenter.default.post(
            name: service.didChangeNotification,
            object: service
        )
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))

        XCTAssertTrue(viewController.updateTableViewAnimatedCalled)
        XCTAssertEqual(viewController.oldCount, 1)
        XCTAssertEqual(viewController.newCount, 2)
    }

    // MARK: - Тест 6: Презентер обновляет photos после успешного лайка

    func testPresenterUpdatesPhotosAfterChangeLikeSuccess() {
        let service = ImagesListServiceSpy()
        let presenter = ImagesListPresenter(imagesListService: service)
        service.photos = [makePhoto(id: "1", isLiked: true)]
        service.changeLikeResult = .success(())

        presenter.changeLike(photoId: "1", isLiked: true) { _ in }

        XCTAssertTrue(service.changeLikeCalled)
        XCTAssertEqual(presenter.photos.first?.id, "1")
        XCTAssertEqual(presenter.photos.first?.isLiked, true)
    }

    // MARK: - Тест 7: Презентер возвращает ошибку при неуспешном лайке

    func testPresenterReturnsFailureWhenChangeLikeFails() {
        let service = ImagesListServiceSpy()
        let presenter = ImagesListPresenter(imagesListService: service)
        service.changeLikeResult = .failure(ImagesListServiceSpyError.test)
        var receivedError: Error?

        presenter.changeLike(photoId: "1", isLiked: true) { result in
            if case .failure(let error) = result {
                receivedError = error
            }
        }

        XCTAssertTrue(service.changeLikeCalled)
        XCTAssertNotNil(receivedError)
    }

    private func makePhoto(id: String, isLiked: Bool = false) -> Photo {
        Photo(
            id: id,
            size: CGSize(width: 100, height: 200),
            createdAt: nil,
            description: nil,
            thumbImageURL: "https://example.com/thumb-\(id).jpg",
            largeImageURL: "https://example.com/large-\(id).jpg",
            isLiked: isLiked
        )
    }
}
