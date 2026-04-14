//
//  ImageFeedUITests1.swift
//  ImageFeedUITests1
//
//  Created by Alekhina Viktoriya on 14/04/2026.
//

import XCTest

final class ImageFeedUITests1: XCTestCase {
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testAuth() throws {
        //insert your data here
        let login = ""
        let password = ""
        
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
        authButton.tap()

        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 10))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        loginTextField.tap()
        loginTextField.typeText(login)
        webView.swipeUp()

        let passwordSecureField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordSecureField.waitForExistence(timeout: 5))
        passwordSecureField.tap()
        passwordSecureField.typeText(password)
        webView.swipeUp()

        let loginButton = webView.buttons["Login"]
        loginButton.tap()

        let firstCell = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
    }

    func testFeed() throws {
        let firstCell = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))

        let lastCellIndex = app.tables.cells.count - 1
        if lastCellIndex > 0 {
            let lastCell = app.tables.cells.element(boundBy: lastCellIndex)
            app.tables.element.swipeUp()
            XCTAssertTrue(lastCell.waitForExistence(timeout: 5))
        }

        let likeButton = firstCell.buttons["Like"]
        XCTAssertTrue(likeButton.exists)
        likeButton.tap()
        likeButton.tap()

        firstCell.tap()

        let scrollView = app.scrollViews.element(boundBy: 0)
        XCTAssertTrue(scrollView.exists)

        scrollView.pinch(withScale: 2, velocity: 1)
        scrollView.pinch(withScale: 0.5, velocity: -1)

        let navBackButton = app.buttons["nav back button white"]
        if navBackButton.exists {
            navBackButton.tap()
        } else {
            let fallbackButton = app.buttons.element(boundBy: 0)
            if fallbackButton.exists {
                fallbackButton.tap()
            }
        }
    }

    func testProfile() throws {
        let tabBarsQuery = app.tabBars
        let profileTab = tabBarsQuery.buttons.element(boundBy: 1)
        XCTAssertTrue(profileTab.exists)
        profileTab.tap()

        let fullName = app.staticTexts["Vikosse Osipova"]
        XCTAssertTrue(fullName.waitForExistence(timeout: 5))

        let userName = app.staticTexts["@vikosse"]
        XCTAssertTrue(userName.waitForExistence(timeout: 5))

        let logoutButton = app.buttons["logout button"]
        XCTAssertTrue(logoutButton.exists)
        logoutButton.tap()
    }
}
