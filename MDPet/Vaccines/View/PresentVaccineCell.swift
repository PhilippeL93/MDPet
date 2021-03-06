//
//  PresentVaccineCell.swift
//  MDPet
//
//  Created by Philippe on 21/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit

class PresentVaccineCell: UITableViewCell {

    @IBOutlet weak var vaccineInjectionLabel: UILabel!
    @IBOutlet weak var vaccineDateLabel: UILabel!
    @IBOutlet weak var diseaseOneLabel: UILabel!
    @IBOutlet weak var diseaseTwoLabel: UILabel!
    @IBOutlet weak var diseaseThreeLabel: UILabel!
    @IBOutlet weak var diseaseFourLabel: UILabel!
    @IBOutlet weak var diseaseFiveLabel: UILabel!
    @IBOutlet weak var diseaseSixLabel: UILabel!
    @IBOutlet weak var diseaseSevenLabel: UILabel!
    @IBOutlet weak var diseaseEightLabel: UILabel!

    private let localeLanguage = Locale(identifier: "FR-fr")
    private var dateFormatter = DateFormatter()
    private var diseasesToDisplay: [String] = []

    func configureVaccineCell(with vaccineItem: VaccinesItem) {
        vaccineInjectionLabel.text = vaccineItem.vaccineInjection
        if vaccineItem.vaccineDate != nil {
            dateFormatter.locale = localeLanguage
            dateFormatter.dateFormat = dateFormatddMMyyyyWithSlashes
            let consultationDate = dateFormatter.string(from: vaccineItem.vaccineDate!)
            vaccineDateLabel.text = consultationDate
        } else {
            vaccineDateLabel.text = ""
        }
        diseasesToDisplay = []

        manageDiseasesLabel()

        for indice in 0...vaccineItem.vaccineDiseases!.count-1
        where vaccineItem.vaccineSwitchDiseases![indice] == true {
            diseasesToDisplay.append(vaccineItem.vaccineDiseases![indice])
        }
        guard diseasesToDisplay.count > 0 else {
            return
        }
        manageDiseasesDisplay()
    }
    private func manageDiseasesLabel() {
        diseaseOneLabel.isHidden = true
        diseaseTwoLabel.isHidden = true
        diseaseThreeLabel.isHidden = true
        diseaseFourLabel.isHidden = true
        diseaseFiveLabel.isHidden = true
        diseaseSixLabel.isHidden = true
        diseaseSevenLabel.isHidden = true
        diseaseEightLabel.isHidden = true
        diseaseOneLabel.text = ""
        diseaseTwoLabel.text = ""
        diseaseThreeLabel.text = ""
        diseaseFourLabel.text = ""
        diseaseFiveLabel.text = ""
        diseaseSixLabel.text = ""
        diseaseSevenLabel.text = ""
        diseaseEightLabel.text = ""
    }
    private func manageDiseasesDisplay() {
        for indice in 0...diseasesToDisplay.count-1 {
            switch indice {
            case 0:
                diseaseOneLabel.isHidden = false
                diseaseOneLabel.text = diseasesToDisplay[indice]
                diseaseTwoLabel.isHidden = false
            case 1:
                diseaseTwoLabel.isHidden = false
                diseaseTwoLabel.text = diseasesToDisplay[indice]
            case 2:
                diseaseThreeLabel.isHidden = false
                diseaseThreeLabel.text = diseasesToDisplay[indice]
                diseaseFourLabel.isHidden = false
            case 3:
                diseaseFourLabel.isHidden = false
                diseaseFourLabel.text = diseasesToDisplay[indice]
            case 4:
                diseaseFiveLabel.isHidden = false
                diseaseFiveLabel.text = diseasesToDisplay[indice]
                diseaseSixLabel.isHidden = false
            case 5:
                diseaseSixLabel.isHidden = false
                diseaseSixLabel.text = diseasesToDisplay[indice]
            case 6:
                diseaseSevenLabel.isHidden = false
                diseaseSevenLabel.text = diseasesToDisplay[indice]
                diseaseEightLabel.isHidden = false
            case 7:
                diseaseEightLabel.isHidden = false
                diseaseEightLabel.text = diseasesToDisplay[indice]
            default: break
            }
        }
    }
}
