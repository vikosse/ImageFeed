//
//  ProfilePresenterSpy.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 14/04/2026.
//
import UIKit
@testable import ImageFeed


// MARK: - ProfilePresenterSpy

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }
}

// MARK: - ProfileViewControllerSpy

final class ProfileViewControllerSpy: UIViewController, ProfileViewControllerProtocol {

    var presenter: ProfilePresenterProtocol?

    var updateProfileDetailsCalled = false
    var updatedName: String?
    var updatedLoginName: String?
    var updatedBio: String?

    var updateAvatarCalled = false
    var updatedAvatarURL: URL?

    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
    }

    func updateProfileDetails(name: String, loginName: String, bio: String) {
        updateProfileDetailsCalled = true
        updatedName = name
        updatedLoginName = loginName
        updatedBio = bio
    }

    func updateAvatar(url: URL) {
        updateAvatarCalled = true
        updatedAvatarURL = url
    }
}

// MARK: - ImagesListPresenterSpy

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    var photos: [Photo] = []
    var viewDidLoadCalled = false
    var fetchNextPageCalled = false

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
    ) {}
}

// MARK: - ImagesListViewControllerSpy

final class ImagesListViewControllerSpy: UIViewController, ImagesListViewControllerProtocol {

    var presenter: ImagesListPresenterProtocol?

    var reloadTableViewCalled = false
    var updateTableViewAnimatedCalled = false
    var updatedOldCount: Int?
    var updatedNewCount: Int?
    var showLikeErrorCalled = false

    func configure(_ presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
    }

    func reloadTableView() {
        reloadTableViewCalled = true
    }

    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        updateTableViewAnimatedCalled = true
        updatedOldCount = oldCount
        updatedNewCount = newCount
    }

    func showLikeError() {
        showLikeErrorCalled = true
    }
}

