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

    private var dateFormatter = DateFormatter()
    private let localeLanguage = Locale(identifier: "FR-fr")

    func configurePetCell(petsItem: PetsItem, callback: @escaping (Bool) -> Void ) {
        petPicture.image = nil
        petNameLabel.text = petsItem.petName
        if petsItem.petBirthDate != nil {
            dateFormatter.locale = localeLanguage
            dateFormatter.dateFormat = dateFormatddMMMMyyyyWithSpaces
            let birthDate = dateFormatter.string(from: petsItem.petBirthDate!)
            petBirthDateLabel.text = birthDate
        } else {
            petBirthDateLabel.text = ""
        }
        guard let imageData = petsItem.petPicture else {
            return callback(true)
        }
        petPicture.image = UIImage(data: imageData)
        callback(true)
    }
}
