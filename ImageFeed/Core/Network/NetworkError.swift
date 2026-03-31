//
//  NetworkError.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 30/03/2026.
//

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
}
