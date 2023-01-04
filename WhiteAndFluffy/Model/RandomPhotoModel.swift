//
//  RandomPhotoModel.swift
//  WhiteAndFluffy
//
//  Created by Alexander Senin on 04.01.2023.
//

import Foundation

struct RandomPhotoModel: Codable {
    let createdAt: String
    let id: String
    let urls: UrlsRand
    let user: UserRand
    let location: Location?
    let downloads: Int
    
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case id, urls, user, location, downloads
    }
}

struct UrlsRand: Codable {
    let small: String
}

struct UserRand: Codable {
    let username: String
}

struct Location: Codable {
    let city, country: String?
    let position: Position?
}

struct Position: Codable {
    let latitude, longitude: Double?
}
