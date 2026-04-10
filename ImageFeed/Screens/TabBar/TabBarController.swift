//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 29/03/2026.
//
import UIKit

// MARK: - TabBarController

final class TabBarController: UITabBarController {

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupTabBar()
    }

    // MARK: - Private Methods

    private func setupTabBar() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)

        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        )
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabEditorialActive),
            selectedImage: nil
        )

        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabProfileActive),
            selectedImage: nil
        )

        viewControllers = [imagesListViewController, profileViewController]
    }
}
