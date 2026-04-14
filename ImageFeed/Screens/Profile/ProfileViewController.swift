//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 22/02/2026.
//
import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {

    // MARK: - Private properties
    private var presenter: ProfilePresenterProtocol?
    private var animationLayers = Set<CALayer>()

    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let usernameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let logoutButton = UIButton()
    
    // MARK: - Configure

    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(resource: .ypBlack)

        setupAvatar()
        setupLogoutButton()
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        setupName()
        setupUserName()
        setupDescription()

        presenter?.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2

        guard animationLayers.isEmpty else { return }

        addGradient(to: avatarImageView, cornerRadius: avatarImageView.bounds.width / 2)
        addGradient(to: nameLabel, cornerRadius: 9)
        addGradient(to: usernameLabel, cornerRadius: 9)
        addGradient(to: descriptionLabel, size: CGSize(width: 67, height: 18), cornerRadius: 9)
    }

    // MARK: - UI Setup

    private func setupAvatar() {
        avatarImageView.image = UIImage(resource: .defaultUserPic)
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true

        view.addSubview(avatarImageView)
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
    }

    private func setupName() {
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameLabel.textColor = UIColor(resource: .ypWhite)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(nameLabel)
        nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor).isActive = true
    }

    private func setupLogoutButton() {
        logoutButton.setImage(UIImage(resource: .logoutButton), for: .normal)
        logoutButton.accessibilityIdentifier = "logout button"
        logoutButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(logoutButton)
        NSLayoutConstraint.activate([
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 45)
        ])
    }

    private func setupUserName() {
        usernameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        usernameLabel.textColor = UIColor(resource: .ypGray)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(usernameLabel)
        usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        usernameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor).isActive = true
    }

    private func setupDescription() {
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = UIColor(resource: .ypWhite)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: logoutButton.trailingAnchor)
        ])
    }

    // MARK: - Actions

    @objc
    private func didTapLogoutButton() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        let yesAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            ProfileLogoutService.shared.logout()
            self?.switchToSplashViewController()
        }
        alert.addAction(yesAction)
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel))
        present(alert, animated: true)
    }

    private func switchToSplashViewController() {
        guard let window = UIApplication.shared.keyWindowScene else {
            assertionFailure("Invalid window configuration")
            return
        }
        window.rootViewController = SplashViewController()
    }

    private func addGradient(to view: UIView, size: CGSize? = nil, cornerRadius: CGFloat = 0) {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: size ?? view.bounds.size)
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 0.3).cgColor,
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 0.3).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = cornerRadius
        gradient.masksToBounds = true

        let animation = CABasicAnimation(keyPath: "locations")
        animation.duration = 1.0
        animation.repeatCount = .infinity
        animation.fromValue = [0, 0.1, 0.3]
        animation.toValue = [0, 0.8, 1]
        gradient.add(animation, forKey: "locationsChange")

        view.layer.addSublayer(gradient)
        animationLayers.insert(gradient)
    }
}

// MARK: - ProfileViewControllerProtocol

extension ProfileViewController: ProfileViewControllerProtocol {

    func updateProfileDetails(name: String, loginName: String, bio: String) {
        animationLayers.forEach { $0.removeFromSuperlayer() }
        animationLayers.removeAll()

        nameLabel.text = name
        usernameLabel.text = loginName
        descriptionLabel.text = bio
    }

    func updateAvatar(url: URL) {
        animationLayers.forEach { $0.removeFromSuperlayer() }
        animationLayers.removeAll()

        avatarImageView.kf.setImage(with: url, placeholder: UIImage(resource: .defaultUserPic))
    }
}
