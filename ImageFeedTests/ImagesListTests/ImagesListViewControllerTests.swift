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

    // MARK: - Properties

    private var service: ImagesListServiceSpy!
    private var presenter: ImagesListPresenter!
    private var viewControllerSpy: ImagesListViewControllerSpy!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        service = ImagesListServiceSpy()
        presenter = ImagesListPresenter(imagesListService: service)
        viewControllerSpy = ImagesListViewControllerSpy()
        presenter.view = viewControllerSpy
    }

    override func tearDown() {
        service = nil
        presenter = nil
        viewControllerSpy = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testViewControllerCallsViewDidLoad() {
        // Given
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: ImagesListViewController.self))
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController
        let presenterSpy = ImagesListPresenterSpy()
        viewController.configure(presenterSpy)

        // When
        _ = viewController.view

        // Then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }

    func testPresenterCallsFetchPhotosNextPageOnViewDidLoad() {
        // Given

        // When
        presenter.viewDidLoad()

        // Then
        XCTAssertTrue(service.fetchPhotosNextPageCalled)
    }

    func testPresenterCallsFetchPhotosNextPage() {
        // Given

        // When
        presenter.fetchNextPage()

        // Then
        XCTAssertTrue(service.fetchPhotosNextPageCalled)
    }

    func testPresenterCallsReloadTableViewWhenPhotosLoaded() {
        // Given
        service.photos = [makePhoto(id: "1")]

        // When
        presenter.viewDidLoad()
        NotificationCenter.default.post(
            name: service.didChangeNotification,
            object: service
        )
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))

        // Then
        XCTAssertTrue(viewControllerSpy.reloadTableViewCalled)
    }

    func testPresenterCallsUpdateTableViewAnimatedWhenPhotosAdded() {
        // Given
        service.photos = [makePhoto(id: "1")]

        // When
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

        // Then
        XCTAssertTrue(viewControllerSpy.updateTableViewAnimatedCalled)
        XCTAssertEqual(viewControllerSpy.oldCount, 1)
        XCTAssertEqual(viewControllerSpy.newCount, 2)
    }

    func testPresenterUpdatesPhotosAfterChangeLikeSuccess() {
        // Given
        service.photos = [makePhoto(id: "1", isLiked: true)]
        service.changeLikeResult = .success(())

        // When
        presenter.changeLike(photoId: "1", isLiked: true) { _ in }

        // Then
        XCTAssertTrue(service.changeLikeCalled)
        XCTAssertEqual(presenter.photos.first?.id, "1")
        XCTAssertEqual(presenter.photos.first?.isLiked, true)
    }

    func testPresenterReturnsFailureWhenChangeLikeFails() {
        // Given
        service.changeLikeResult = .failure(ImagesListServiceSpyError.test)
        var receivedError: Error?

        // When
        presenter.changeLike(photoId: "1", isLiked: true) { result in
            if case .failure(let error) = result {
                receivedError = error
            }
        }

        // Then
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
