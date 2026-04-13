//
//  URLRequest+Extensions.swift
//  ImageFeed
//
//  Created by Alekhina Viktoriya on 11/04/2026.
//
import Foundation

extension URLRequest {
    static func authorizedRequest(
        url: URL,
        method: HTTPMethod,
        token: String
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
