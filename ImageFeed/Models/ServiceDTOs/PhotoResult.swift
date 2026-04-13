//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 06/04/2026.
//
import Foundation
import CoreGraphics

struct PhotoResult: Codable {
    let id: String
    let createdAt: String?
    let width: Int
    let height: Int
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case likedByUser = "liked_by_user"
        case description
        case urls
    }
}

extension PhotoResult {
    private static let dateFormatter = ISO8601DateFormatter()

    var photo: Photo {
        Photo(
            id: id,
            size: CGSize(width: CGFloat(width), height: CGFloat(height)),
            createdAt: createdAt
                .flatMap {
                    Self.dateFormatter.date(from: $0)
                },
            description: description,
            thumbImageURL: urls.thumb,
            largeImageURL: urls.full,
            isLiked: likedByUser
        )
    }
}
