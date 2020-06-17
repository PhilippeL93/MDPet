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

    func configurePetCell(name: String, URLPicture: String, birthDate: String, callback: @escaping (Bool) -> Void ) {
        petPicture.image = nil

        GetFirebasePicture.shared.getPicture(URLPicture: URLPicture) { (success, picture) in
            if success, let picture = picture {
                self.petPicture.image = picture
            }
            self.petNameLabel.text = name
            self.petBirthDateLabel.text = birthDate
        }
        callback(true)
    }
}
