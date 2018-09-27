//
//  ApiManager.swift
//  BookChart
//
//  Created by Quang Nguyen on 9/26/18.
//  Copyright © 2018 Quang Nguyen. All rights reserved.
//

import Foundation

class ApiManager {
    
    static let shared = ApiManager()
    
    func fetchData(fromUrlString urlStr: String, completionHandler: @escaping (NSDictionary) -> Void) {
        let url = URL(string: urlStr)
        fetchData(fromUrl: url!, completionHandler: completionHandler)
    }
    
    func fetchData(fromUrl url: URL, completionHandler: @escaping (NSDictionary) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                
                if let json = json as? NSDictionary {
                    completionHandler(json)
                }
            } catch let jsonError {
                print("JSON ERROR: \(jsonError)")
            }
        }
        task.resume()
    }
    
}
