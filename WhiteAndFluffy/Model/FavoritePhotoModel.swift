//
//  FavoritePhotoModel.swift
//  WhiteAndFluffy
//
//  Created by Alexander Senin on 04.01.2023.
//

import Foundation

struct FavoritePhotoModel: Codable {
    let createdAt: String
    let id: String
    let urls: UrlsFav
    let user: UserFav
    
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case id, urls, user
    }
}

struct UrlsFav: Codable {
    let small: String
}

struct UserFav: Codable {
    let username: String
    let location: String?
}
