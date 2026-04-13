//
//  UIApplication+keyWindow.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 11/04/2026.
//
import UIKit

extension UIApplication {
    var keyWindowScene: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}
