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

        func observeVaccines(callback: @escaping (Bool, [VaccineItem]) -> Void) {
            let path = UserUid.uid + "-pets-item"

            databaseRef = Database.database().reference(withPath: "\(path)")

            let query = databaseRef.queryOrdered(byChild: "vaccineNumber")
            query.observe(.value, with: { snapshot in
                var newItems: [VaccineItem] = []
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot,
                        let vaccineItem = VaccineItem(snapshot: snapshot) {
                        newItems.append(vaccineItem)
                    }
                }
                newItems.reverse()
                self.vaccineItems = newItems
                callback(true, self.vaccineItems)
            })
        }
}
