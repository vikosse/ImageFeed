//
//  WebViewPresenterSpy.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 14/04/2026.
//
import Foundation
@testable import ImageFeed

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    weak var view: WebViewViewControllerProtocol?
    var viewDidLoadCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func didUpdateProgressValue(_ newValue: Double) {}

    func code(from url: URL) -> String? {
        nil
    }
}
