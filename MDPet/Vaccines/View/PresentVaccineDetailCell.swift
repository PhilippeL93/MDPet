//
//  PresentVaccineDetailCell.swift
//  MDPet
//
//  Created by Philippe on 07/07/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit

protocol TableViewClickVaccine: AnyObject {
    func onClickCellVaccine(index: Int, switchDisease: Bool)
}

class PresentVaccineDetailCell: UITableViewCell {

    @IBOutlet weak var diseaseLabel: UILabel!
    @IBOutlet weak var switchDisease: UISwitch!

    @IBAction func touchUpSwitchDisease(_ sender: UISwitch) {
        cellDelegateVaccine?.onClickCellVaccine(index: (indexSelected?.row)!, switchDisease: switchDisease.isOn)
    }

    weak var cellDelegateVaccine: TableViewClickVaccine?
    var indexSelected: IndexPath?

    func configureVaccineDetailCell(with vaccineDiseases: String, vaccineDiseaseSwitch: Bool) {
        diseaseLabel.text = vaccineDiseases
        switchDisease.isOn = vaccineDiseaseSwitch
    }
}
