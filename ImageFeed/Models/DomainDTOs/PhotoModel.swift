//
//  Photo.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 06/04/2026.
//
import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let description: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

extension Photo {
    func with(isLiked: Bool) -> Photo {
        Photo(
            id: id,
            size: size,
            createdAt: createdAt,
            description: description,
            thumbImageURL: thumbImageURL,
            largeImageURL: largeImageURL,
            isLiked: isLiked
        )
    }
}
