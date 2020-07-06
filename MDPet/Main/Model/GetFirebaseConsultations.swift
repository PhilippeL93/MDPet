//
//  GetFirebaseConsultations.swift
//  MDPet
//
//  Created by Philippe on 02/07/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import Foundation
import Firebase

class GetFirebaseConsultations {

    static let shared = GetFirebaseConsultations()
    var databaseRef = Database.database().reference(withPath: "consultations-item")
    var consultationItems: [ConsultationItem] = []
    var newItems: [ConsultationItem] = []

    private let localeLanguage = Locale(identifier: "FR-fr")
    private var dateFormatter = DateFormatter()

    func observeConsultations(callback: @escaping (Bool, [ConsultationItem]) -> Void) {
        let path = UserUid.uid + "-pets-item"

        databaseRef = Database.database().reference(withPath: "\(path)")

        let query = databaseRef.queryOrdered(byChild: "consultationDate")
        query.observe(.value, with: { snapshot in
            self.newItems = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                    let consultationItem = ConsultationItem(snapshot: snapshot) {
                    self.newItems.append(consultationItem)
                }
            }
            if self.newItems.count != 0 {
                self.dateFormatter.locale = self.localeLanguage
                self.sortTable(wayToSort: "fromDMAToAMD")
                self.newItems = self.newItems.sorted(by: {
                    $0.consultationDate > $1.consultationDate
                })
                self.sortTable(wayToSort: "fromAMDToDMA")
            }
            self.consultationItems = self.newItems
            callback(true, self.consultationItems)
        })
    }
    private func sortTable(wayToSort: String) {
        for indice in 0...newItems.count-1 {
            if wayToSort == "fromDMAToAMD" {
                dateFormatter.dateFormat = "dd MMMM yyyy"
            } else {
                dateFormatter.dateFormat = "yyyyMMdd"
            }
            let dateNewFormat = self.dateFormatter.date(from: newItems[indice].consultationDate)
            if wayToSort == "fromDMAToAMD" {
                dateFormatter.dateFormat = "yyyyMMdd"
            } else {
                dateFormatter.dateFormat = "dd MMMM yyyy"
            }
            let dateInverted = self.dateFormatter.string(from: dateNewFormat!)
            newItems[indice].consultationDate = dateInverted
        }
    }
}
