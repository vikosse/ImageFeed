//
//  WebViewViewControllerSpy.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 14/04/2026.
//
import Foundation
@testable import ImageFeed

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?
    var loadRequestCalled = false
    var progressValue: Float?
    var progressHidden: Bool?

    func load(request: URLRequest) {
        loadRequestCalled = true
    }

    func setProgressValue(_ newValue: Float) {
        progressValue = newValue
    }

    func setProgressHidden(_ isHidden: Bool) {
        progressHidden = isHidden
    }
}
