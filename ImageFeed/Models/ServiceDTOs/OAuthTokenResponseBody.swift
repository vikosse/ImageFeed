//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 07/03/2026.
//

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
        
        private enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
        }
}
