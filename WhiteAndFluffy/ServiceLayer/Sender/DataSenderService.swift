//
//  DataSenderService.swift
//  WhiteAndFluffy
//
//  Created by Alexander Senin on 04.01.2023.
//

import Foundation

protocol DataSenderServiceProtocol {
    func sendPhotoLike(photoId: String, completion: @escaping (Int?) -> Void)
    func sendPhotoUnlike(photoId: String, completion: @escaping (Int?) -> Void)
}

class DataSenderService: DataSenderServiceProtocol {
    
    var networkDataSender: DataSenderProtocol
    
    init(networkDataSender: DataSenderProtocol = NetworkDataSender()) {
        self.networkDataSender = networkDataSender
    }
    
    func sendPhotoLike(photoId: String, completion: @escaping (Int?) -> Void) {
        let url = Constants.URLS.likePhotoUrl(photoId: photoId)
        let httpMethod = Constants.HTTPMethods.post
        networkDataSender.sendGenericJSONData(url: url, httpMethod: httpMethod, jsonResponse: completion)
    }
    
    func sendPhotoUnlike(photoId: String, completion: @escaping (Int?) -> Void) {
        let url = Constants.URLS.likePhotoUrl(photoId: photoId)
        let httpMethod = Constants.HTTPMethods.delete
        networkDataSender.sendGenericJSONData(url: url, httpMethod: httpMethod, jsonResponse: completion)
    }
}
