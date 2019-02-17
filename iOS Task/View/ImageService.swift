//
//  ImageService.swift
//  iOS Task
//
//  Created by Medhat Mebed on 2/16/19.
//  Copyright © 2019 Medhat Mebed. All rights reserved.
//

import Foundation
import UIKit

class ImageService {
    
    static let cache = NSCache<NSString, UIImage>()
    /**
     This function will download the image from url parameter and return UIImage with url for key in cashe dictionary
     */
    static func downloadImage(withURL url:URL, completion: @escaping (_ image:UIImage?, _ url:URL)->()) {
        let dataTask = URLSession.shared.dataTask(with: url) { data, responseURL, error in
            var downloadedImage:UIImage?
            
            if let data = data {
                downloadedImage = UIImage(data: data)
            }
            if downloadedImage != nil {
                cache.setObject(downloadedImage!, forKey: url.absoluteString as NSString)
            }
            DispatchQueue.main.async {
                completion(downloadedImage, url)
            }
        }
        
        dataTask.resume()
    }
    
    /**
     This function will get the image from cashe if not exists it calls the downloadImage func
     */
    static func getImage(withURL url:URL, completion: @escaping (_ image:UIImage?, _ url:URL)->()) {
        if let image = cache.object(forKey: url.absoluteString as NSString) {
            completion(image, url)
        } else {
            downloadImage(withURL: url, completion: completion)
        }
    }
}
