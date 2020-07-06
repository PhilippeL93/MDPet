//
//  GetFirebaseVaccines.swift
//  MDPet
//
//  Created by Philippe on 26/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import Foundation
import Firebase

class GetFirebaseVaccines {

    static let shared = GetFirebaseVaccines()
    var databaseRef = Database.database().reference(withPath: "vacciness-item")
    var vaccineItems: [VaccineItem] = []
    var newItems: [VaccineItem] = []

    private let localeLanguage = Locale(identifier: "FR-fr")
    private var dateFormatter = DateFormatter()

    func observeVaccines(petKey: String, callback: @escaping (Bool, [VaccineItem]) -> Void) {
        let path = UserUid.uid + "-vaccines-item" + petKey

        databaseRef = Database.database().reference(withPath: "\(path)")

        let query = databaseRef.queryOrdered(byChild: "vaccineDate")
        query.observe(.value, with: { snapshot in
            self.newItems = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                    let vaccineItem = VaccineItem(snapshot: snapshot) {
                    self.newItems.append(vaccineItem)
                }
            }
            if self.newItems.count != 0 {
                self.dateFormatter.locale = self.localeLanguage
                self.sortTable(wayToSort: "fromDMAToAMD")
                self.newItems = self.newItems.sorted(by: {
                    $0.vaccineDate > $1.vaccineDate
                })
                self.sortTable(wayToSort: "fromAMDToDMA")
            }
            self.vaccineItems = self.newItems
            callback(true, self.vaccineItems)
        })
    }
    private func sortTable(wayToSort: String) {
        for indice in 0...newItems.count-1 {
            if wayToSort == "fromDMAToAMD" {
                dateFormatter.dateFormat = "dd MMMM yyyy"
            } else {
                dateFormatter.dateFormat = "yyyyMMdd"
            }
            let dateNewFormat = self.dateFormatter.date(from: newItems[indice].vaccineDate)
            if wayToSort == "fromDMAToAMD" {
                dateFormatter.dateFormat = "yyyyMMdd"
            } else {
                dateFormatter.dateFormat = "dd MMMM yyyy"
            }
            let dateInverted = self.dateFormatter.string(from: dateNewFormat!)
            newItems[indice].vaccineDate = dateInverted
        }
    }
}
