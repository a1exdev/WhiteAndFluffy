//
//  SearchPhotoModel.swift
//  WhiteAndFluffy
//
//  Created by Alexander Senin on 04.01.2023.
//

import Foundation

struct SearchPhotoModel: Codable {
    let results: [QueryPhotoModel]
}

struct QueryPhotoModel: Codable {
    let createdAt: String
    let id: String
    let urls: Urls
    let user: User

    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case id, urls, user
    }
}

struct Urls: Codable {
    let small: String
}

struct User: Codable {
    let username: String
    let location: String?
}
