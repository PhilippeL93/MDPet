//
//  PresentPetsCell.swift
//  MDPet
//
//  Created by Philippe on 05/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit
import FirebaseStorage

class PresentPetsCell: UITableViewCell {

    @IBOutlet weak var petPicture: UIImageView!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var petBirthDateLabel: UILabel!

    let imageCache = NSCache<NSString, AnyObject>()

    func configurePetCell(with name: String, picture: String, birthDate: String ) {
        petNameLabel.text = name
        petBirthDateLabel.text = birthDate
        petPicture.image = nil
        if let cachedImage = imageCache.object(forKey: picture as NSString) as? UIImage {
            petPicture.image = cachedImage
            return
        }

        let url = URL(string: picture)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if let error = error {
//                print(error)
                return
            }
            DispatchQueue.main.async(execute: {
                if let downloadedImage = UIImage(data: data!) {
                    self.imageCache.setObject(downloadedImage, forKey: picture as NSString)
                    self.petPicture.image = downloadedImage
                }
            })
        }).resume()
    }
}
