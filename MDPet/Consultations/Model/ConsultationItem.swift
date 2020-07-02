//
//  ConsultationItem.swift
//  MDPet
//
//  Created by Philippe on 02/07/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import Foundation
import Firebase

struct ConsultationItem {

    let ref: DatabaseReference?
    let key: String
    var consultationNumber: Int
    var consultationName: String
    var consultationDate: String
    var consultationVeterinary: String
    var consultationDiseases: [String]

    init(name: String, key: String = "",
         number: Int, date: String,
         veterinary: String, diseases: [String]) {
        self.ref = nil
        self.key = key
        self.consultationNumber = number
        self.consultationName = name
        self.consultationDate = date
        self.consultationVeterinary = veterinary
        self.consultationDiseases = diseases
    }

    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let consultationNumber = value["consultationNumber"] as? Int,
            let consultationName = value["consultationName"] as? String,
            let consultationDate = value["consultationDate"] as? String,
            let consultationVeterinary = value["consultationVetrinary"] as? String,
            let consultationDiseases = value["consultationDiseaes"] as? [String]
            else {
                return nil
        }

        self.ref = snapshot.ref
        self.key = snapshot.key
        self.consultationNumber = consultationNumber
        self.consultationName = consultationName
        self.consultationDate = consultationDate
        self.consultationVeterinary = consultationVeterinary
        self.consultationDiseases = consultationDiseases
  }

    func toAnyObject() -> Any {
        return [
            "consultationNumber": consultationNumber,
            "consultationName": consultationName,
            "consultationDate": consultationDate,
            "consultationVeterinary": consultationVeterinary,
            "consultationDiseases": consultationDiseases
        ]
    }
}
