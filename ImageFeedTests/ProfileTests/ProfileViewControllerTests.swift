//
//  ProfileViewControllerTests.swift
//  ImageFeedTests
//
//  Created by Alekhina Viktoriya on 15/04/2026.
//

import XCTest
@testable import ImageFeed

@MainActor
final class ProfileViewControllerTests: XCTestCase {

    // MARK: - Тест 1: Контроллер вызывает viewDidLoad презентера

    func testViewControllerCallsViewDidLoad() {
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.configure(presenter)

        _ = viewController.view

        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    // MARK: - Тест 2: Презентер передает данные профиля во view

    func testPresenterCallsUpdateProfileDetails() {
        let viewController = ProfileViewControllerSpy()
        let profileService = ProfileServiceSpy()
        let profileImageService = ProfileImageServiceSpy()
        let presenter = ProfilePresenter(
            profileService: profileService,
            profileImageService: profileImageService
        )
        let profile = Profile(
            username: "test_user",
            name: "Test User",
            loginName: "@test_user",
            bio: "Test bio"
        )
        profileService.profile = profile
        presenter.view = viewController

        presenter.viewDidLoad()

        XCTAssertTrue(viewController.updateProfileDetailsCalled)
        XCTAssertEqual(viewController.name, profile.name)
        XCTAssertEqual(viewController.loginName, profile.loginName)
        XCTAssertEqual(viewController.bio, profile.bio)
    }

    // MARK: - Тест 3: Презентер передает URL аватара во view

    func testPresenterCallsUpdateAvatar() {
        let viewController = ProfileViewControllerSpy()
        let profileService = ProfileServiceSpy()
        let profileImageService = ProfileImageServiceSpy()
        let presenter = ProfilePresenter(
            profileService: profileService,
            profileImageService: profileImageService
        )
        profileImageService.avatarURL = "https://example.com/avatar.jpg"
        presenter.view = viewController

        presenter.viewDidLoad()

        XCTAssertTrue(viewController.updateAvatarCalled)
        XCTAssertEqual(viewController.avatarURL?.absoluteString, profileImageService.avatarURL)
    }

    // MARK: - Тест 4: Презентер обновляет аватар после уведомления

    func testPresenterUpdatesAvatarWhenNotificationPosted() {
        let viewController = ProfileViewControllerSpy()
        let profileService = ProfileServiceSpy()
        let profileImageService = ProfileImageServiceSpy()
        let presenter = ProfilePresenter(
            profileService: profileService,
            profileImageService: profileImageService
        )
        presenter.view = viewController
        presenter.viewDidLoad()

        profileImageService.avatarURL = "https://example.com/new-avatar.jpg"
        NotificationCenter.default.post(
            name: profileImageService.didChangeNotification,
            object: profileImageService
        )
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))

        XCTAssertTrue(viewController.updateAvatarCalled)
        XCTAssertEqual(viewController.avatarURL?.absoluteString, profileImageService.avatarURL)
    }
}

private final class ProfilePresenterSpy: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }
}

private final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var updateProfileDetailsCalled = false
    var updateAvatarCalled = false
    var name: String?
    var loginName: String?
    var bio: String?
    var avatarURL: URL?

    func updateProfileDetails(name: String, loginName: String, bio: String) {
        updateProfileDetailsCalled = true
        self.name = name
        self.loginName = loginName
        self.bio = bio
    }

    func updateAvatar(url: URL) {
        updateAvatarCalled = true
        avatarURL = url
    }
}

private final class ProfileServiceSpy: ProfileServiceProtocol {
    var profile: Profile?
}

private final class ProfileImageServiceSpy: ProfileImageServiceProtocol {
    var avatarURL: String?
    let didChangeNotification = Notification.Name("ProfileImageServiceSpyDidChange")
}
