//
//  APIservice.swift
//  iOS Task
//
//  Created by Medhat Mebed on 2/17/19.
//  Copyright © 2019 Medhat Mebed. All rights reserved.
//

import Foundation
import UIKit

class APIService: NSObject {
    
    let endPoint: String = {
        return "https://limitless-forest-98976.herokuapp.com"
    }()
    
    func getDataWith(completion: @escaping (Result<[[String: AnyObject]]>) -> Void) {
        
        
        guard let url = URL(string: endPoint) else { return completion(.Error("Invalid URL, we can't update your feed")) }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard error == nil else { return completion(.Error(error!.localizedDescription)) }
            guard let data = data else { return completion(.Error(error?.localizedDescription ?? "There are no new Items to show"))
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? [String: AnyObject] {
                    guard let productDataArray = json["data"] as? [[String: AnyObject]] else {
                        return completion(.Error(error?.localizedDescription ?? "There are no new Items to show"))
                    }
                    DispatchQueue.main.async {
                        completion(.Success(productDataArray))
                    }
                }
            } catch let error {
                return completion(.Error(error.localizedDescription))
            }
            }.resume()
    }
}

enum Result<T> {
    case Success(T)
    case Error(String)
}





