//
//  PresentPetsCell.swift
//  MDPet
//
//  Created by Philippe on 05/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit

class PresentPetsCell: UITableViewCell {

    @IBOutlet weak var petPicture: UIImageView!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var petBirthDateLabel: UILabel!

    func configurePetCell(with name: String, picture: String, birthDate: String ) {
        petNameLabel.text = name
        petBirthDateLabel.text = birthDate
    }
}
