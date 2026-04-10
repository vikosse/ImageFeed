//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 08/04/2026.
//

import Foundation
import WebKit

final class ProfileLogoutService {
    
    static let shared = ProfileLogoutService()
    
    // MARK: - Private properties
    
    private let tokenStorage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let imagesListService = ImagesListService.shared
    
    // MARK: - Initializers
    
    private init() {}
    
    // MARK: - Public methods
    
    func logout() {
        tokenStorage.removeToken()
        profileService.resetProfile()
        profileImageService.resetAvatar()
        imagesListService.resetPhotos()
        cleanCookies()
    }
    
    // MARK: - Private methods
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()
        ) { records in
            records.forEach { record in
                dataStore.removeData(
                    ofTypes: record.dataTypes,
                    for: [record],
                    completionHandler: {}
                )
            }
        }
    }
}
