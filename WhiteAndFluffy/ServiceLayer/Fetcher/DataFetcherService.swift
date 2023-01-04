//
//  DataFetcherService.swift
//  WhiteAndFluffy
//
//  Created by Alexander Senin on 04.01.2023.
//

import Foundation

protocol DataFetcherServiceProtocol {
    func fetchPhotosByQuery(query: String, completion: @escaping (SearchPhotoModel?) -> Void)
    func fetchRandomPhotos(completion: @escaping ([RandomPhotoModel]?) -> Void)
    func fetchFavoritePhotos(completion: @escaping ([FavoritePhotoModel]?) -> Void)
}

class DataFetcherService: DataFetcherServiceProtocol {
    
    var networkDataFetcher: DataFetcherProtocol
    
    init(networkDataFetcher: DataFetcherProtocol = NetworkDataFetcher()) {
        self.networkDataFetcher = networkDataFetcher
    }
    
    func fetchPhotosByQuery(query: String, completion: @escaping (SearchPhotoModel?) -> Void) {
        let url = Constants.URLS.fetchPhotoByQueryUrl(query: query)
        networkDataFetcher.fetchGenericJSONData(url: url, jsonResponse: completion)
    }
    
    func fetchRandomPhotos(completion: @escaping ([RandomPhotoModel]?) -> Void) {
        let url = Constants.URLS.fetchRandomPhotosUrl(count: 30)
        networkDataFetcher.fetchGenericJSONData(url: url, jsonResponse: completion)
    }
    
    func fetchFavoritePhotos(completion: @escaping ([FavoritePhotoModel]?) -> Void) {
        let url = Constants.URLS.fetchFavoritePhotosUrl(userId: "a1exdev")
        networkDataFetcher.fetchGenericJSONData(url: url, jsonResponse: completion)
    }
}
