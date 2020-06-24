//
//  getFirebasePicture.swift
//  MDPet
//
//  Created by Philippe on 14/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import Foundation
import FirebaseStorage

class GetFirebasePicture {

    static let shared = GetFirebasePicture()

    let imageCache = NSCache<NSString, AnyObject>()

    func getPicture(URLPicture: String, callback: @escaping (Bool, UIImage?) -> Void) {
        let url = URL(string: URLPicture)
        if url != nil {
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                if let error = error {
                    print(error)
                    return
                }
                guard response != nil else {
                    return
                }
                DispatchQueue.main.async(execute: {
                    if let downloadedImage = UIImage(data: data!) {
                        self.imageCache.setObject(downloadedImage, forKey: URLPicture as NSString)
                        callback(true, downloadedImage)
                    }
                })
            }).resume()
        }
        callback(false, nil)
    }
}
