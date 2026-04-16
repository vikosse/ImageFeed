//
//  ImagesListViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Alekhina Viktoriya on 15/04/2026.
//

import Foundation
@testable import ImageFeed

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var updateTableViewAnimatedCalled = false
    var reloadTableViewCalled = false
    var showLikeErrorCalled = false
    var oldCount: Int?
    var newCount: Int?

    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        updateTableViewAnimatedCalled = true
        self.oldCount = oldCount
        self.newCount = newCount
    }

    func reloadTableView() {
        reloadTableViewCalled = true
    }

    func showLikeError() {
        showLikeErrorCalled = true
    }
}
