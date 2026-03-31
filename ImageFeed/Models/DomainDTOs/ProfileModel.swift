//
//  ProfileModel.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 24/03/2026.
//
import Foundation

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

extension Profile {
    init(from result: ProfileResult) {
        self.username = result.username
        
        let firstName = result.firstName
        let lastName = result.lastName ?? ""
        self.name = "\(firstName) \(lastName)"
            .trimmingCharacters(in: .whitespaces)
        
        self.loginName = "@\(result.username)"
        self.bio = result.bio
    }
}
