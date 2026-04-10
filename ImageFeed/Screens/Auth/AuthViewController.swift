//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 02/03/2026.
//
import UIKit

// import ProgressHUD

// MARK: - AuthViewControllerDelegate

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}
// MARK: - AuthViewController

final class AuthViewController: UIViewController {

    // MARK: - Properties

    private let showWebViewSegueIdentifier = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared

    weak var delegate: AuthViewControllerDelegate?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard let webViewViewController = segue.destination as? WebViewViewController else {
                assertionFailure(
                    "Failed to prepare for \(showWebViewSegueIdentifier)"
                )
                return
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    // MARK: - Private Methods

    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(
            resource: .backButton
        )
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(
            resource: .backButton
        )
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: nil,
            action: nil
        )
        navigationItem.backBarButtonItem?.tintColor = UIColor(
            resource: .ypBlack
        )
    }
}

// MARK: - WebViewViewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {

    func webViewViewController(
        _ vc: WebViewViewController,
        didAuthenticateWithCode code: String
    ) {
        vc.dismiss(animated: true)

        UIBlockingProgressHUD.show()

        fetchOAuthToken(code) { [weak self] result in
            guard let self else { return }

            UIBlockingProgressHUD.dismiss()

            switch result {
            case .success:
                self.delegate?.didAuthenticate(self)

            case .failure(let error):
                print(
                    "[AuthViewController.webViewViewController]: failure - error: \(error.localizedDescription)"
                )
                self.showAuthErrorAlert()
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}

// MARK: - Private helpers
extension AuthViewController {

    private func fetchOAuthToken(
        _ code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        oauth2Service.fetchOAuthToken(code, completion: completion)
    }

    private func showAuthErrorAlert() {
        let alertController = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(
            title: "Ок",
            style: .default
        )

        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}
