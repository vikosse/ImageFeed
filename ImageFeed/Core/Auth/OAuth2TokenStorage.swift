//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 07/03/2026.
//
import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()

    private let tokenKey = "OAuth2Token"

    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let newValue {
                KeychainWrapper.standard.set(newValue, forKey: tokenKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }

    func removeToken() {
        token = nil
    }
    
    private init() {}
}
