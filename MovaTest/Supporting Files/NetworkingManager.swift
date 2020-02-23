//
//  NetworkingManager.swift
//  MovaTest
//
//  Created by Danil Shchegol on 21.02.2020.
//  Copyright © 2020 Danil Shchegol. All rights reserved.
//

import Foundation

final class NetworkingManager {
    
    static let shared = NetworkingManager()
    
    private init() {}
    
    private let searchRoute = "http://api.giphy.com/v1/gifs/search"
    private let apiKey = "rvpQrqfXdwvf11p0gncLIrqpoZSY08xE"
    
    func searchGIF(with text: String, completion: @escaping (PhotoQuery?, String?) -> Void) {
        guard var urlComponents = URLComponents(string: searchRoute) else { completion(nil, "Incorrect route"); return }
        //adding API parameters to URL
        urlComponents.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "q", value: text),
            URLQueryItem(name: "limit", value: "10")
        ]
        
        guard let url = urlComponents.url else { completion(nil, "Incorrect URL"); return }
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard // check response validation
                let data = data,
                let response = response as? HTTPURLResponse,
                (200 ..< 300) ~= response.statusCode, error == nil
                else {
                    DispatchQueue.main.async {
                        completion(nil, error?.localizedDescription)
                    }
                    return
            }
            // convert JSON data to dictionary
            let responseObject = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
            // if founded GIFs' count more than zero, then we choose random GIF and parse JSON to create Realm model
            if let gifs = responseObject?["data"] as? [[String: Any]], gifs.count > 0,
                let gif = gifs.randomElement(), let id = gif["id"] as? String,
                let images = gif["images"] as? [String: Any],
                let fixedHeight = images["fixed_height"] as? [String: Any],
                let url = fixedHeight["url"] as? String {
                DispatchQueue.main.async {
                    completion(PhotoQuery(id: id, url: url, query: text), nil)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil, "No GIFs found")
                }
            }
        }
        task.resume()
    }
}
