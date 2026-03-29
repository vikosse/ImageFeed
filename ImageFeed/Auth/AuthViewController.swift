//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 02/03/2026.
//
import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController, WebViewViewControllerDelegate {
    
    // MARK: - Internal properties
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Private properties
    private let showWebViewSegueIdentifier = "ShowWebView"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == showWebViewSegueIdentifier {
            guard let webViewVC = segue.destination as? WebViewViewController else { return }
            webViewVC.delegate = self
        }
    }
    
    // MARK: - Private methods
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(resource: .backButton)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(resource: .backButton)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(resource: .ypBlack)
    }
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        UIBlockingProgressHUD.show()
        
        OAuth2Service.shared.fetchOAuthToken(code) {  result in
            
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success:
                vc.navigationController?.popViewController(animated: true) //TODO: ??? needed or not
                self.delegate?.didAuthenticate(self)
                
            case .failure(let error):
                print("Failed to fetch OAuth token: \(error)")
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.navigationController?.popViewController(animated: true)
    }
}
