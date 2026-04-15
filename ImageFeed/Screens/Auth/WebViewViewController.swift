//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 02/03/2026.
//
import UIKit
import WebKit

// MARK: - WebViewViewControllerProtocol

protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

// MARK: - WebViewViewController

final class WebViewViewController: UIViewController & WebViewViewControllerProtocol {

    // MARK: - IBOutlets & IBActions
    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet private weak var progressView: UIProgressView!

    // MARK: - Internal properties
    
    weak var delegate: WebViewViewControllerDelegate?
    var presenter: WebViewPresenterProtocol?

    // MARK: - Private properties
    
    private var progressObservation: NSKeyValueObservation?

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        webView.accessibilityIdentifier = "UnsplashWebView"

        presenter?.viewDidLoad()

        progressObservation = webView.observe(
            \.estimatedProgress,
            options: [.new]
        ) { [weak self] _, change in
            guard let newValue = change.newValue else { return }
            self?.presenter?.didUpdateProgressValue(newValue)
        }
    }

    // MARK: - WebViewViewControllerProtocol methods

    func load(request: URLRequest) {
        webView.load(request)
    }

    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }

    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
}

// MARK: - WKNavigationDelegate

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
            return presenter?.code(from: url)
        }
        return nil
    }
}
