//
//  UserResult.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 30/03/2026.
//

struct UserResult: Codable {
    let profileImage: ProfileImage

    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}
