//
//  NetworkDataSender.swift
//  WhiteAndFluffy
//
//  Created by Alexander Senin on 04.01.2023.
//

import Foundation

protocol DataSenderProtocol {
    func sendGenericJSONData(url: String, httpMethod: String, jsonResponse: @escaping (Int?) -> Void)
}

class NetworkDataSender: DataSenderProtocol {
    
    var networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func sendGenericJSONData(url: String, httpMethod: String, jsonResponse: @escaping (Int?) -> Void) {
        networkService.request(url: url, httpMethod: httpMethod) { data, response, error in
            guard error == nil else {
                print("Error: error calling DELETE")
                print(error!.localizedDescription)
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
                jsonResponse(response.statusCode)
                
                guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("Error: Cannot convert data to JSON")
                    return
                }
                guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
                    print("Error: Cannot convert JSON object to Pretty JSON data")
                    return
                }
                guard let _ = String(data: prettyJsonData, encoding: .utf8) else {
                    print("Error: Could print JSON in String")
                    return
                }
            } catch {
                print("Error: Trying to convert JSON data to string")
                return
            }
        }
    }
}
