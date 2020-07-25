//
//  GetFirebasePets.swift
//  MDPet
//
//  Created by Philippe on 24/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import Foundation
import Firebase

class GetFirebasePets {

    static let shared = GetFirebasePets()
    var databaseRef = Database.database().reference(withPath: petsItem)
    var petItems: [PetItem] = []

    func observePets(callback: @escaping (Bool, [PetItem]) -> Void) {
        let path = UserUid.uid + petsItem

        databaseRef = Database.database().reference(withPath: "\(path)")

        let query = databaseRef.queryOrdered(byChild: "petName")
        query.observe(.value, with: { snapshot in
            var newItems: [PetItem] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                    let petItem = PetItem(snapshot: snapshot) {
                    newItems.append(petItem)
                }
            }
            self.petItems = newItems
            callback(true, self.petItems)
        })
    }
    func readPets(veterinaryToSearch: String, callback: @escaping (Bool, Bool) -> Void) {
        let path = UserUid.uid + petsItem

        var veterinaryFound = false

        databaseRef = Database.database().reference(withPath: "\(path)")

        let query = databaseRef.queryOrdered(byChild: "petVeterinary")
        query.observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                    let petItem = PetItem(snapshot: snapshot) {
                    if petItem.petVeterinary == veterinaryToSearch {
                       veterinaryFound = true
                    }
                }
            }
            callback(true, veterinaryFound)
        })
    }
}
