//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 07/03/2026.
//
import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Private properties
    private let storage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let tabBarViewControllerIdentifier = "TabBarViewController"
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .vector)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLogo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let token = storage.token else {
            showAuthViewController()
            return
        }
                
        fetchProfile(token: token)
    }
    
    // MARK: - Private methods
    private func setupView() {
        view.backgroundColor = UIColor(resource: .ypBlack)
    }
        
    private func setupLogo() {
        view.addSubview(logoImageView)
            
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func showAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        guard let authViewController = storyboard.instantiateViewController(
            withIdentifier: "AuthViewController"
        ) as? AuthViewController else {
            assertionFailure("Failed to instantiate AuthViewController")
            return
        }
        
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        
        profileService.fetchProfile(token) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let profile):
                ProfileImageService.shared
                    .fetchProfileImageURL(username: profile.username) { _ in }
                UIBlockingProgressHUD.dismiss()
                self.switchToTabBarController()
                
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                print(
                    "[SplashViewController.fetchProfile]: failure - error: \(error.localizedDescription)"
                )
            }
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.keyWindowScene else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(
                withIdentifier: tabBarViewControllerIdentifier
            )

        window.rootViewController = tabBarController
    }
}

// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        guard let token = storage.token else {
            return
        }
                
        fetchProfile(token: token)
    }
}
