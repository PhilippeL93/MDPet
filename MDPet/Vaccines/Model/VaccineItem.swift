//
//  VaccineItem.swift
//  MDPet
//
//  Created by Philippe on 26/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import Foundation
import FirebaseDatabase

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
    var vaccineSwitchDiseases: [Bool]
    var vaccineDone: Bool

    init(name: String, key: String = "",
         number: Int, injection: String,
         date: String, URLThumbnail: String,
         veterinary: String,
         diseases: [String],
         switchDiseasess: [Bool],
         done: Bool) {
        self.ref = nil
        self.key = key
        self.vaccineNumber = number
        self.vaccineInjection = injection
        self.vaccineName = name
        self.vaccineDate = date
        self.vaccineURLThumbnail = URLThumbnail
        self.vaccineVeterinary = veterinary
        self.vaccineDiseases = diseases
        self.vaccineSwitchDiseases = switchDiseasess
        self.vaccineDone = done
    }

    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let vaccineNumber = value["vaccineNumber"] as? Int,
            let vaccineInjection = value["vaccineInjection"] as? String,
            let vaccineName = value["vaccineName"] as? String,
            let vaccineDate = value["vaccineDate"] as? String,
            let vaccineURLThumbnail = value["vaccineURLThumbnail"] as? String,
            let vaccineVeterinary = value["vaccineVeterinary"] as? String,
            let vaccineDiseases = value["vaccineDiseases"] as? [String],
            let vaccineSwitchDiseases = value["vaccineSwitchDiseases"] as? [Bool],
            let vaccineDone = value["vaccineDone"] as? Bool
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
        self.vaccineSwitchDiseases = vaccineSwitchDiseases
        self.vaccineDone = vaccineDone
  }

    func toAnyObject() -> Any {
        return [
            "vaccineNumber": vaccineNumber,
            "vaccineInjection": vaccineInjection,
            "vaccineName": vaccineName,
            "vaccineDate": vaccineDate,
            "vaccineURLThumbnail": vaccineURLThumbnail,
            "vaccineVeterinary": vaccineVeterinary,
            "vaccineDiseases": vaccineDiseases,
            "vaccineSwitchDiseases": vaccineSwitchDiseases,
            "vaccineDone": vaccineDone
        ]
    }
}
