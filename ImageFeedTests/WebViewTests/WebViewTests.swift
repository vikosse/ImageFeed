//
//  WebViewTests.swift
//  ImageFeedTests
//
//  Created by Alekhina Viktoriya on 14/04/2026.
//

import XCTest
@testable import ImageFeed

@MainActor
final class WebViewTests: XCTestCase {

    // MARK: - Тест 1: Контроллер вызывает viewDidLoad презентера

    func testViewControllerCallsViewDidLoad() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: WebViewViewController.self))
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "WebViewViewController"
        ) as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController

        _ = viewController.view

        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    // MARK: - Тест 2: Презентер вызывает loadRequest у контроллера

    func testPresenterCallsLoadRequest() {
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController

        presenter.viewDidLoad()

        XCTAssertTrue(viewController.loadRequestCalled)
    }

    // MARK: - Тест 3: Прогресс виден, когда меньше 1

    func testProgressVisibleWhenLessThenOne() {
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6

        let shouldHideProgress = presenter.shouldHideProgress(for: progress)

        XCTAssertFalse(shouldHideProgress)
    }

    // MARK: - Тест 4: Прогресс скрыт, когда равен 1

    func testProgressHiddenWhenOne() {
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1.0

        let shouldHideProgress = presenter.shouldHideProgress(for: progress)

        XCTAssertTrue(shouldHideProgress)
    }

    // MARK: - Тест 5: AuthHelper формирует корректный URL

    func testAuthHelperAuthURL() {
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)

        let url = authHelper.authURL()

        guard let urlString = url?.absoluteString else {
            XCTFail("Auth URL is nil")
            return
        }

        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }

    // MARK: - Тест 6: AuthHelper корректно извлекает code из URL

    func testCodeFromURL() {
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
        let url = urlComponents.url!
        let authHelper = AuthHelper()

        let code = authHelper.code(from: url)

        XCTAssertEqual(code, "test code")
    }
}
