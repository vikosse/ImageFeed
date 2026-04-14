//
//  ImagesListTests.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 14/04/2026.
//
@testable import ImageFeed
import XCTest

final class ImagesListTests: XCTestCase {

    // MARK: - Тест 1: Контроллер вызывает viewDidLoad презентера

    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)

        //when
        _ = viewController.view

        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    // MARK: - Тест 2: Презентер вызывает reloadTableView на контроллере

    func testPresenterCallsReloadTableView() {
        //given
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)

        //when
        viewController.reloadTableView()

        //then
        XCTAssertTrue(viewController.reloadTableViewCalled)
    }

    // MARK: - Тест 3: Презентер вызывает updateTableViewAnimated на контроллере

    func testPresenterCallsUpdateTableViewAnimated() {
        //given
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)

        //when
        viewController.updateTableViewAnimated(oldCount: 10, newCount: 20)

        //then
        XCTAssertTrue(viewController.updateTableViewAnimatedCalled)
        XCTAssertEqual(viewController.updatedOldCount, 10)
        XCTAssertEqual(viewController.updatedNewCount, 20)
    }
}
