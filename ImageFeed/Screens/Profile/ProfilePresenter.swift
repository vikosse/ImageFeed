//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 14/04/2026.
//
import Foundation

// MARK: - ProfileViewControllerProtocol

protocol ProfileViewControllerProtocol: AnyObject {
    func updateProfileDetails(name: String, loginName: String, bio: String)
    func updateAvatar(url: URL)
}

// MARK: - ProfilePresenterProtocol

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
}

// MARK: - ProfileServiceProtocol

protocol ProfileServiceProtocol: AnyObject {
    var profile: Profile? { get }
}

// MARK: - ProfileImageServiceProtocol

protocol ProfileImageServiceProtocol: AnyObject {
    var avatarURL: String? { get }
    var didChangeNotification: Notification.Name { get }
}

// MARK: - ProfilePresenter

final class ProfilePresenter: ProfilePresenterProtocol {

    // MARK: - Properties

    weak var view: ProfileViewControllerProtocol?

    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private var profileImageServiceObserver: NSObjectProtocol?

    // MARK: - Init

    init(
        profileService: ProfileServiceProtocol = ProfileService.shared,
        profileImageService: ProfileImageServiceProtocol = ProfileImageService.shared
    ) {
        self.profileService = profileService
        self.profileImageService = profileImageService
    }

    // MARK: - ProfilePresenterProtocol

    func viewDidLoad() {
        if let profile = profileService.profile {
            view?.updateProfileDetails(
                name: profile.name,
                loginName: profile.loginName,
                bio: profile.bio ?? ""
            )
        }

        updateAvatarIfNeeded()

        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: profileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatarIfNeeded()
        }
    }

    // MARK: - Private

    private func updateAvatarIfNeeded() {
        guard
            let avatarURLString = profileImageService.avatarURL,
            let url = URL(string: avatarURLString)
        else { return }

        view?.updateAvatar(url: url)
    }

    deinit {
        if let profileImageServiceObserver {
            NotificationCenter.default.removeObserver(profileImageServiceObserver)
        }
    }
}

// MARK: - ProfileServiceProtocol

extension ProfileService: ProfileServiceProtocol {}

// MARK: - ProfileImageServiceProtocol

extension ProfileImageService: ProfileImageServiceProtocol {
    var didChangeNotification: Notification.Name {
        Self.didChangeNotification
    }
}
