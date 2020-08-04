//
//  GetFirebasePets.swift
//  MDPet
//
//  Created by Philippe on 24/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import Foundation
import FirebaseDatabase

class GetFirebasePets {

    static let shared = GetFirebasePets(with: DatabaseReference())
    private var databaseReference: DatabaseReference
    var petItems: [PetItem] = []

    init(with databaseReference: DatabaseReference) {
        self.databaseReference = databaseReference
        let path = UserUid.uid
        self.databaseReference = Database.database().reference(withPath: "\(path)").child(petsItem)
    }

    func observePets(callback: @escaping (Bool, [PetItem]) -> Void) {
        self.databaseReference
            .queryOrdered(byChild: "petName")
            .observe(.value, with: { snapshot in
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
    func readPets(veterinaryToSearch: String, callback: @escaping (Bool) -> Void) {
        var veterinaryFound = false
        self.databaseReference
            .observeSingleEvent(of: .value) {snapshot in
                var newItems: [PetItem] = []
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot,
                        let petItem = PetItem(snapshot: snapshot) {
                        if petItem.petVeterinary == veterinaryToSearch {
                            veterinaryFound = true
                        }
                        newItems.append(petItem)
                    }
                }
                if veterinaryFound == true {
                    callback(veterinaryFound)
                } else {
                    self.readVaccines(petItems: self.petItems,
                                      veterinaryToSearch: veterinaryToSearch,
                                      callback: callback)
                    self.readConsultations(petItems: self.petItems,
                                           veterinaryToSearch: veterinaryToSearch,
                                           callback: callback)
                }
        }
    }
    private func readVaccines(petItems: [PetItem],
                              veterinaryToSearch: String,
                              callback: @escaping((Bool) -> Void )) {
        for indice in 0...self.petItems.count-1 {
            let petKey = self.petItems[indice].key
            GetFirebaseVaccines.shared.readVaccines(petKey: petKey,
                                                    veterinaryToSearch: veterinaryToSearch) { (found) in
                                                        if found == true {
                                                            callback(found)
                                                        }
            }
        }
    }
    private func readConsultations(petItems: [PetItem],
                                   veterinaryToSearch: String,
                                   callback: @escaping((Bool) -> Void )) {
        for indice in 0...self.petItems.count-1 {
            let petKey = self.petItems[indice].key
            GetFirebaseConsultations.shared.readConsultations(petKey: petKey,
                                                              veterinaryToSearch: veterinaryToSearch) { (found) in
                                                                if found == true {
                                                                    callback(found)
                                                                }
            }
        }
    }
}
