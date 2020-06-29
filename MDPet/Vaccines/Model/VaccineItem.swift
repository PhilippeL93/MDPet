//
//  VaccineItem.swift
//  MDPet
//
//  Created by Philippe on 26/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import Foundation
import Firebase

struct VaccineItem {

    let ref: DatabaseReference?
    let key: String
    var vaccineNumber: Int
    var vaccineInjection: String
    var vaccineName: String
    var vaccineDate: String
    var vaccineURLThumbnail: String
    var vaccineVeterinary: String
    var vaccineDiseases: [String]
//    var vaccineDiseaseDetail: Diseases
//    var vaccineChlamydia: String
//    var vaccineCoryza: String
//    var vaccineLeukemia: String
//    var vaccineRabies: String
//    var vaccineTyphus: String

    init(name: String, key: String = "",
         number: Int, injection: String,
         date: String, URLThumbnail: String,
         veterinary: String, diseases: [String]) {
//         chlamydia: String,
//         coryza: String, leukemia: String,
//         rabies: String, typhus: String) {
        self.ref = nil
        self.key = key
        self.vaccineNumber = number
        self.vaccineInjection = injection
        self.vaccineName = name
        self.vaccineDate = date
        self.vaccineURLThumbnail = URLThumbnail
        self.vaccineVeterinary = veterinary
        self.vaccineDiseases = diseases
//        self.vaccineChlamydia = chlamydia
//        self.vaccineCoryza = coryza
//        self.vaccineLeukemia = leukemia
//        self.vaccineRabies = rabies
//        self.vaccineTyphus = typhus
    }

    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let vaccineNumber = value["vaccineNumber"] as? Int,
            let vaccineInjection = value["vaccineInjection"] as? String,
            let vaccineName = value["vaccineName"] as? String,
            let vaccineDate = value["vaccineDate"] as? String,
            let vaccineURLThumbnail = value["vaccineURLThumbnail"] as? String,
            let vaccineVeterinary = value["vaccineVetrinary"] as? String,
            let vaccineDiseases = value["vaccineDiseaes"] as? [String]
//            let vaccineChlamydia = value["vaccineChlamydia"] as? String,
//            let vaccineCoryza = value["vaccineCoryza"] as? String ,
//            let vaccineLeukemia = value["vaccineLeukemia"] as? String,
//            let vaccineRabies = value["vaccineRabies"] as? String,
//            let vaccineTyphus = value["vaccineTyphus"] as? String
            else {
                return nil
        }

        self.ref = snapshot.ref
        self.key = snapshot.key
        self.vaccineNumber = vaccineNumber
        self.vaccineInjection = vaccineInjection
        self.vaccineName = vaccineName
        self.vaccineDate = vaccineDate
        self.vaccineURLThumbnail = vaccineURLThumbnail
        self.vaccineVeterinary = vaccineVeterinary
        self.vaccineDiseases = vaccineDiseases
//        self.vaccineChlamydia = vaccineChlamydia
//        self.vaccineCoryza = vaccineCoryza
//        self.vaccineLeukemia = vaccineLeukemia
//        self.vaccineRabies = vaccineRabies
//        self.vaccineTyphus = vaccineTyphus
  }

    func toAnyObject() -> Any {
        return [
            "vaccineNumber": vaccineNumber,
            "vaccineInjection": vaccineInjection,
            "vaccineName": vaccineName,
            "vaccineDate": vaccineDate,
            "vaccineURLThumbnail": vaccineURLThumbnail,
            "vaccineVeterinary": vaccineVeterinary,
            "vaccineDiseases": vaccineDiseases
//            "vaccineChlamydia": vaccineChlamydia,
//            "vaccineCoryza": vaccineCoryza,
//            "vaccineLeukemia": vaccineLeukemia,
//            "vaccineRabies": vaccineRabies,
//            "vaccineTyphus": vaccineTyphus
        ]
    }
}

struct Diseases {
    var diseaseName : String
    var diseaseIsOn: Bool
}
