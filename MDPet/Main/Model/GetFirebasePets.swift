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
    var databaseRef = Database.database().reference(withPath: "pets-item")
    var petItems: [PetItem] = []

        func observePets(callback: @escaping (Bool, [PetItem]) -> Void) {
            let path = UserUid.uid + "-pets-item"

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

    //        databaseRef.queryOrdered(byChild: "veterinaryName").observe(.value, with: { snapshot in
    //            var newItems: [VeterinaryItem] = []
    //            for child in snapshot.children {
    //                if let snapshot = child as? DataSnapshot,
    //                    let veterinaryItem = VeterinaryItem(snapshot: snapshot) {
    //                    newItems.append(veterinaryItem)
    //                }
    //            }
    //            self.veterinariesItems = newItems
    //            print("====================== self.veterinariesItems \(self.veterinariesItems.count)")
    //            callback(true, self.veterinariesItems)
    //            print("===================== self.veterinariesItems \(self.veterinariesItems)")
    //        })

    //        Auth.auth().addStateDidChangeListener { auth, user in
    //            guard let user = user else { return }
    //            self.user = User(authData: user)
    //            let currentUserRef = self.usersRef.child(self.user.uid)
    //            currentUserRef.setValue(self.user.email)
    //            currentUserRef.onDisconnectRemoveValue()
    //        }
        }
}
