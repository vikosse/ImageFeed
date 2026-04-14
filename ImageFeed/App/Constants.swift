//
//  Constants.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 01/03/2026.
//
import Foundation

// MARK: - Constants

enum Constants {
    static let accessKey = "MqPEcwMTqgc8MnGd64yBmR3B22_G3uNjCZczeSjlQqM"
    static let secretKey = "fhBtFaDu12paj3M6CtH7wRr7Voc3yvtClxLJXD5kkrg"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURLString = "https://api.unsplash.com"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

enum APIConstants {
    static let defaultScheme = "https"
    static let unsplashHost = "unsplash.com"
    static let unsplashAPIHost = "api.unsplash.com"

    static let authPath = "/oauth/token"
    static let mePath = "/me"
    static let photosPath = "/photos"

    static func userProfilePath(username: String) -> String {
        "/users/\(username)"
    }

    static func photoLikePath(photoId: String) -> String {
        "/photos/\(photoId)/like"
    }
}

// MARK: - AuthConfiguration

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURLString: String
    let authURLString: String

    init(
        accessKey: String,
        secretKey: String,
        redirectURI: String,
        accessScope: String,
        authURLString: String,
        defaultBaseURLString: String
    ) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.authURLString = authURLString
        self.defaultBaseURLString = defaultBaseURLString
    }

    static var standard: AuthConfiguration {
        return AuthConfiguration(
            accessKey: Constants.accessKey,
            secretKey: Constants.secretKey,
            redirectURI: Constants.redirectURI,
            accessScope: Constants.accessScope,
            authURLString: Constants.unsplashAuthorizeURLString,
            defaultBaseURLString: Constants.defaultBaseURLString
        )
    }
}
