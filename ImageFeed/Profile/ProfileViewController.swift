//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 22/02/2026.
//
import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - Private properties
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let usernameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let logoutButton = UIButton()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAvatar()
        setName()
        setUserName()
        setDescription()
        setLogoutButton()
    }
    
    // MARK: - UI setup
    private func setAvatar() {
        avatarImageView.image = UIImage(resource: .avatar)
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarImageView)
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
    }
    
    private func setName() {
        nameLabel.text = "Екатерина Новикова"
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameLabel.textColor = UIColor(resource: .ypWhite)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        nameLabel.topAnchor
            .constraint(
                equalTo: avatarImageView.bottomAnchor,
                constant: 8
            ).isActive = true
        nameLabel.leadingAnchor
            .constraint(equalTo: avatarImageView.leadingAnchor).isActive = true
    }
    
    private func setUserName() {
        usernameLabel.text = "@ekaterina_nov"
        usernameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        usernameLabel.textColor = UIColor(resource: .ypGray)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(usernameLabel)
        usernameLabel.topAnchor
            .constraint(
                equalTo: nameLabel.bottomAnchor,
                constant: 8
            ).isActive = true
        usernameLabel.leadingAnchor
            .constraint(equalTo: avatarImageView.leadingAnchor).isActive = true
    }
    
    private func setDescription() {
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = UIColor(resource: .ypWhite)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        descriptionLabel.topAnchor
            .constraint(
                equalTo: usernameLabel.bottomAnchor,
                constant: 8
            ).isActive = true
        descriptionLabel.leadingAnchor
            .constraint(equalTo: avatarImageView.leadingAnchor).isActive = true
    }
    
    private func setLogoutButton() {
        logoutButton.setImage(UIImage(resource: .logoutButton), for: .normal)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        NSLayoutConstraint.activate([
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.trailingAnchor
                .constraint(
                    equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                    constant: -16
                ),
            logoutButton.topAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 45)
        ])
    }
}
