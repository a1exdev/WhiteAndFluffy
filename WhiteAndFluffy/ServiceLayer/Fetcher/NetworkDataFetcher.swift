//
//  NetworkDataFetcher.swift
//  WhiteAndFluffy
//
//  Created by Alexander Senin on 04.01.2023.
//

import Foundation

protocol DataFetcherProtocol {
    func fetchGenericJSONData<T: Decodable>(url: String, jsonResponse: @escaping (T?) -> Void)
}

class NetworkDataFetcher: DataFetcherProtocol {
    
    var networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func fetchGenericJSONData<T>(url: String, jsonResponse: @escaping (T?) -> Void) where T: Decodable {
        networkService.request(url: url, httpMethod: nil) { [self] (data, response, error) in
            guard error == nil else {
                print("Error: error calling GET")
                print(error!)
                return
            }
            guard let data = data else {
                print("Error: Did not receive data")
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("Error: HTTP request failed")
                return
            }
            do {
                let decoded = decodeJSON(type: T.self, from: data)
                jsonResponse(decoded)
            }
        }
    }
    
    private func decodeJSON<T: Decodable>(type: T.Type, from: Data?) -> T? {
        let decoder = JSONDecoder()
        guard let data = from else { return nil }
        do {
            let objects = try decoder.decode(type.self, from: data)
            return objects
        } catch let jsonError {
            print("Error: Failed to decode JSON.", jsonError.localizedDescription)
            return nil
        }
    }
}
