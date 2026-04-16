//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Alekhina Viktoriya on 14/04/2026.
//

import XCTest

final class ImageFeedUITests1: XCTestCase {
    private let app = XCUIApplication()
    
    //insert your data here
    let login = ""
    let password = ""
    let fullName = ""
    let userName = "@"

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testAuth() throws {

        let authButton = app.buttons["loginButton"]
        XCTAssertTrue(authButton.firstMatch.waitForExistence(timeout: 5))
        authButton.firstMatch.tap()

        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 10))
        
        // скрывает cookies экран
        if app/*@START_MENU_TOKEN@*/.buttons["Close"]/*[[".otherElements.buttons[\"Close\"]",".buttons[\"Close\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.exists {
            app.buttons["Close"].firstMatch.tap()
        }

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        loginTextField.tap()
        loginTextField.typeText(login)
        
        //скрывает клавиатуру
        if app/*@START_MENU_TOKEN@*/.buttons["Done"]/*[[".otherElements.buttons[\"Done\"]",".buttons[\"Done\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.exists {
            app/*@START_MENU_TOKEN@*/.buttons["Done"]/*[[".otherElements.buttons[\"Done\"]",".buttons[\"Done\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        }

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
        let tablesQuery = app.tables
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        sleep(2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        cellToLike.buttons["Heart"].tap()
        cellToLike.buttons["FilledHeart"].tap()
        
        sleep(2)
        
        cellToLike.tap()
        
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
  
        image.pinch(withScale: 3, velocity: 1)

        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["backButton"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {

        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons.element(boundBy: 1).tap()

        let fullName = app.staticTexts[fullName]
        XCTAssertTrue(fullName.waitForExistence(timeout: 5))

        let userName = app.staticTexts[userName]
        XCTAssertTrue(userName.waitForExistence(timeout: 5))

        let logoutButton = app.buttons["logoutButton"]
        XCTAssertTrue(logoutButton.exists)
        logoutButton.tap()
        
        app/*@START_MENU_TOKEN@*/.buttons["Да"]/*[[".otherElements.buttons[\"Да\"]",".buttons[\"Да\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        XCTAssertTrue(app.buttons["loginButton"].firstMatch.waitForExistence(timeout: 5))
    }
}
