//
//  WebViewViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 02/03/2026.
//
import UIKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
