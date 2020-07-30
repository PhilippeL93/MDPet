//
//  ConsultationItem.swift
//  MDPet
//
//  Created by Philippe on 02/07/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct ConsultationItem {

    let ref: DatabaseReference?
    let key: String
    var consultationReason: String
    var consultationDate: String
    var consultationVeterinary: String
    var consultationReport: String
    var consultationWeight: String
    var consultationIdEvent: String
//    var consultationDiseases: [String]

    init(key: String = "",
         reason: String,
         date: String,
         veterinary: String,
         report: String,
         weight: String,
         idEvent: String,
         diseases: [String]) {
        self.ref = nil
        self.key = key
        self.consultationReason = reason
        self.consultationDate = date
        self.consultationVeterinary = veterinary
        self.consultationReport = report
        self.consultationWeight = weight
        self.consultationIdEvent = idEvent
//        self.consultationDiseases = diseases
    }

    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let consultationReason = value["consultationReason"] as? String,
            let consultationDate = value["consultationDate"] as? String,
            let consultationVeterinary = value["consultationVeterinary"] as? String,
            let consultationReport = value["consultationReport"] as? String,
            let consultationWeight = value["consultationWeight"] as? String,
            let consultationIdEvent = value["consultationIdEvent"] as? String
//            let consultationDiseases = value["consultationDiseaes"] as? [String]
            else {
                return nil
        }

        self.ref = snapshot.ref
        self.key = snapshot.key
        self.consultationReason = consultationReason
        self.consultationDate = consultationDate
        self.consultationVeterinary = consultationVeterinary
        self.consultationReport = consultationReport
        self.consultationWeight = consultationWeight
        self.consultationIdEvent = consultationIdEvent
//        self.consultationDiseases = consultationDiseases
  }

    func toAnyObject() -> Any {
        return [
            "consultationReason": consultationReason,
            "consultationDate": consultationDate,
            "consultationVeterinary": consultationVeterinary,
            "consultationReport": consultationReport,
            "consultationWeight": consultationWeight,
            "consultationIdEvent": consultationIdEvent
//            "consultationDiseases": consultationDiseases
        ]
    }
}
