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

    func configureVaccineCell(with vaccineItem: VaccineItem) {
        vaccineInjectionLabel.text = vaccineItem.vaccineInjection
        vaccineDateLabel.text = vaccineItem.vaccineDate

        diseaseOneLabel.isHidden = true
        diseaseTwoLabel.isHidden = true
        diseaseThreeLabel.isHidden = true
        diseaseFourLabel.isHidden = true
        diseaseFiveLabel.isHidden = true
        diseaseSixLabel.isHidden = true
        diseaseSevenLabel.isHidden = true
        diseaseEightLabel.isHidden = true

//        for indice in 0...vaccineItem.vaccineDiseases.count-1 {
//            switch indice {
//            case 0:
////                diseaseOneLabel.text = vaccineItem.vaccineDiseases[indice]
//                diseaseOneLabel.isHidden = false
//                diseaseTwoLabel.isHidden = false
//            case 1:
//                print("=")
////                diseaseTwoLabel.text = vaccineItem.vaccineDiseases[indice]
//            case 2:
////                diseaseThreeLabel.text = vaccineItem.vaccineDiseases[indice]
//                diseaseThreeLabel.isHidden = false
//                diseaseFourLabel.isHidden = false
//            case 3:
////                diseaseFourLabel.text = vaccineItem.vaccineDiseases[indice]
//                print("=")
//            case 4:
////                diseaseFiveLabel.text = vaccineItem.vaccineDiseases[indice]
//                diseaseFiveLabel.isHidden = false
//                diseaseSixLabel.isHidden = false
//            case 5:
////                diseaseSixLabel.text = vaccineItem.vaccineDiseases[indice]
//                print("=")
//            case 6:
////                diseaseSevenLabel.text = vaccineItem.vaccineDiseases[indice]
//                diseaseSevenLabel.isHidden = false
//                diseaseEightLabel.isHidden = false
//            case 7:
////                diseaseEightLabel.text = vaccineItem.vaccineDiseases[indice]
//                print("=")
//            default: break
//            }
//        }
//        diseaseOneLabel.text = vaccineItem.vaccineChlamydia
//        diseaseTwoLabel.text = vaccineItem.vaccineCoryza
//        diseaseThreeLabel.text = vaccineItem.vaccine
//        diseaseFourLabel.text = vaccineItem.vaccine
//        diseaseFiveLabel.text = vaccineItem.vaccine
//        diseaseSixLabel.text = vaccineItem.vaccine
//        diseaseSevenLabel.text = vaccineItem.vaccine
//        diseaseEightLabel.text = vaccineItem.vaccine
    }
}
