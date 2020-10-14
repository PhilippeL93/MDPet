//
//  PresentVeterinaryCell.swift
//  MDPet
//
//  Created by Philippe on 12/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit

protocol TableViewClick: AnyObject {
    func onClickCell(phoneNumber: String)
}

class PresentVeterinaryCell: UITableViewCell {

    @IBOutlet weak var veterinaryNameLabel: UILabel!
    @IBOutlet weak var veterinaryCityLabel: UILabel!
    @IBOutlet weak var veterinaryCallPhoneField: UIButton!

    @IBAction func callVeterinary(_ sender: UIButton) {
        cellDelegate?.onClickCell(phoneNumber: veterinaryPhoneNumber)
    }

    weak var cellDelegate: TableViewClick?
    var veterinaryPhoneNumber = ""

    func configureVeterinaryCell(veterinariesItem: VeterinariesItem) {
        veterinaryNameLabel.text = veterinariesItem.veterinaryName
        veterinaryCityLabel.text = veterinariesItem.veterinaryCity
        veterinaryCallPhoneField.isHidden = true
        if !veterinariesItem.veterinaryPhone!.isEmpty {
            if currentPhoneStatus == .phoneUsable {
                veterinaryPhoneNumber = veterinariesItem.veterinaryPhone!
                veterinaryCallPhoneField.isHidden = false
            }
        }
    }
}
