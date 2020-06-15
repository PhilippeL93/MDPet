//
//  PresentPetCell.swift
//  MDPet
//
//  Created by Philippe on 05/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit

class PresentPetCell: UITableViewCell {

    @IBOutlet weak var petPicture: UIImageView!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var petBirthDateLabel: UILabel!

    let imageCache = NSCache<NSString, AnyObject>()

    func configurePetCell(with name: String, URLPicture: String, birthDate: String ) {
    petNameLabel.text = name
    petBirthDateLabel.text = birthDate
    petPicture.image = nil
        if let cachedImage = imageCache.object(forKey: URLPicture as NSString) as? UIImage {
            petPicture.image = cachedImage
            return
        }
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
                        self.petPicture.image = downloadedImage
                    }
                })
            }).resume()
        }
}

//    func configurePetCell(name: String, URLPicture: String, birthDate: String, callback: @escaping (Bool) -> Void ) {
//        petNameLabel.text = name
//        petBirthDateLabel.text = birthDate
//
//        petPicture.image = nil
//
//        GetFirebasePicture.shared.getPicture(URLPicture: URLPicture) { (success, picture) in
//            if success, let picture = picture {
//                self.petPicture.image = picture
//            }
//        }
//        callback(true)
//    }
}
