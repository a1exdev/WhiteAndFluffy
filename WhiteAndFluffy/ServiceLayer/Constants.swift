//
//  Constants.swift
//  WhiteAndFluffy
//
//  Created by Alexander Senin on 04.01.2023.
//

import Foundation

struct Constants {
    
    struct URLS {
        static func fetchPhotoByQueryUrl(query: String) -> String {
            let url = "https://api.unsplash.com/search/photos?query=\(query)"
            return url
        }
        
        static func fetchRandomPhotosUrl(count: Int) -> String {
            let url = "https://api.unsplash.com/photos/random/?count=\(count)"
            return url
        }
        
        static func fetchFavoritePhotosUrl(userId: String) -> String {
            let url = "https://api.unsplash.com/users/\(userId)/likes"
            return url
        }
        
        static func likePhotoUrl(photoId: String) -> String {
            let url = "https://api.unsplash.com/photos/\(photoId)/like"
            return url
        }
    }
    
    struct AccessKeys {
        static let bearerKey = "Bearer xINnAis3zGiBUbOao4FYmN1mC7q-N4I8Q3Cz4SrFQFY"
    }
    
    struct HTTPMethods {
        static let get = "GET"
        static let post = "POST"
        static let delete = "DELETE"
    }
    
    struct HTTPHeaders {
        static let contentType = "Content-Type"
        static let accept = "Accept"
        static let authorizatiion = "Authorization"
    }
}
