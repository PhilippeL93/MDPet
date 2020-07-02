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

        func observeConsultations(callback: @escaping (Bool, [ConsultationItem]) -> Void) {
            let path = UserUid.uid + "-pets-item"

            databaseRef = Database.database().reference(withPath: "\(path)")

            let query = databaseRef.queryOrdered(byChild: "consultationDate")
            query.observe(.value, with: { snapshot in
                var newItems: [ConsultationItem] = []
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot,
                        let consultationItem = ConsultationItem(snapshot: snapshot) {
                        newItems.append(consultationItem)
                    }
                }
                newItems.reverse()
                self.consultationItems = newItems
                callback(true, self.consultationItems)
            })
        }
}
