//
//  ProfileTests.swift
//  ImageFeedTests
//
//  Created by Alekhina Viktoriya on 14/04/2026.
//

@testable import ImageFeed
import XCTest

final class ProfileTests: XCTestCase {

    // MARK: - Тест 1: Контроллер вызывает viewDidLoad презентера

    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenterSpy()
        viewController.configure(presenter)

        //when
        _ = viewController.view

        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    // MARK: - Тест 2: Презентер вызывает updateProfileDetails на контроллере

    func testPresenterCallsUpdateProfileDetails() {
        //given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenterSpy()
        viewController.configure(presenter)

        //when
        viewController.updateProfileDetails(
            name: "Test Name",
            loginName: "@test",
            bio: "Test bio"
        )

        //then
        XCTAssertTrue(viewController.updateProfileDetailsCalled)
        XCTAssertEqual(viewController.updatedName, "Test Name")
        XCTAssertEqual(viewController.updatedLoginName, "@test")
        XCTAssertEqual(viewController.updatedBio, "Test bio")
    }

    // MARK: - Тест 3: Презентер вызывает updateAvatar на контроллере

    func testPresenterCallsUpdateAvatar() {
        //given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenterSpy()
        viewController.configure(presenter)

        let testURL = URL(string: "https://example.com/avatar.jpg")!

        //when
        viewController.updateAvatar(url: testURL)

        //then
        XCTAssertTrue(viewController.updateAvatarCalled)
        XCTAssertEqual(viewController.updatedAvatarURL, testURL)
    }
}
