//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 24/03/2026.
//
import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        UIApplication.shared.keyWindowScene
    }

    static func show() {
        DispatchQueue.main.async {
            window?.isUserInteractionEnabled = false
            ProgressHUD.animate()
        }
    }

    static func dismiss() {
        DispatchQueue.main.async {
            window?.isUserInteractionEnabled = true
            ProgressHUD.dismiss()
        }
    }
}
