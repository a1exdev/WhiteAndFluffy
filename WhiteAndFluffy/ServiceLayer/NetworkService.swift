//
//  NetworkService.swift
//  WhiteAndFluffy
//
//  Created by Alexander Senin on 04.01.2023.
//

import Foundation

protocol NetworkServiceProtocol {
    func request(url: String, httpMethod: String?, completion: @escaping (Data?, URLResponse?, Error?) -> Void)
}

class NetworkService: NetworkServiceProtocol {
    
    func request(url: String, httpMethod: String? = Constants.HTTPMethods.get, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        guard let url = URL(string: url) else { return }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: Constants.HTTPHeaders.contentType)
        request.setValue("application/json", forHTTPHeaderField: Constants.HTTPHeaders.accept)
        request.setValue(Constants.AccessKeys.bearerKey, forHTTPHeaderField: Constants.HTTPHeaders.authorizatiion)

        if httpMethod != "" && httpMethod != nil {
            guard let httpBody = try? JSONSerialization.data(withJSONObject: [], options: []) else { return }
            request.httpBody = httpBody
            request.httpMethod = httpMethod
        }
        
        let task = createDataTask(from: request, completion: completion)
        task.resume()
    }
    
    private func createDataTask(from request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        
        return URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            DispatchQueue.main.async {
                completion(data, response, error)
            }
        })
    }
}
