//
//  GetFirebaseVeterinaries.swift
//  MDPet
//
//  Created by Philippe on 24/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import Foundation
import Firebase

class GetFirebaseVeterinaries {

    static let shared = GetFirebaseVeterinaries()
    var databaseRef = Database.database().reference(withPath: "veterinaries-item")
    var veterinariesItems: [VeterinaryItem] = []

    func observeVeterinaries(callback: @escaping (Bool, [VeterinaryItem]) -> Void) {
        let path = UserUid.uid + "-veterinaries-item"

        databaseRef = Database.database().reference(withPath: "\(path)")

        let query = databaseRef.queryOrdered(byChild: "veterinaryName")
        query.observe(.value, with: { snapshot in
            var newItems: [VeterinaryItem] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                    let veterinaryItem = VeterinaryItem(snapshot: snapshot) {
                    newItems.append(veterinaryItem)
                }
            }
            self.veterinariesItems = newItems
            callback(true, self.veterinariesItems)
        })
    }
}
