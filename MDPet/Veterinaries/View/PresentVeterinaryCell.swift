//
//  PresentVeterinaryCell.swift
//  MDPet
//
//  Created by Philippe on 12/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit

protocol TableViewClick: AnyObject {
    func onClickCell(index: Int)
}

class PresentVeterinaryCell: UITableViewCell {

    @IBOutlet weak var veterinaryNameLabel: UILabel!
    @IBOutlet weak var veterinaryCityLabel: UILabel!

    @IBAction func callVeterinary(_ sender: UIButton) {
        cellDelegate?.onClickCell(index: (indexSelected?.row)!)
    }

    weak var cellDelegate: TableViewClick?
    var indexSelected: IndexPath?

    func configurePetCell(with name: String, city: String) {
        veterinaryNameLabel.text = name
        veterinaryCityLabel.text = city
    }
}
