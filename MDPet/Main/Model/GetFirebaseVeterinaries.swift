//
//  GetFirebaseVeterinaries.swift
//  MDPet
//
//  Created by Philippe on 24/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import Foundation
import FirebaseDatabase

class GetFirebaseVeterinaries {

    static let shared = GetFirebaseVeterinaries(with: DatabaseReference())
    private var databaseReference: DatabaseReference
    var veterinariesItems: [VeterinaryItem] = []

    init(with databaseReference: DatabaseReference) {
        self.databaseReference = databaseReference
//        ici modif pour architecture
//        let path = UserUid.uid + veterinariesItem
//        self.databaseReference = Database.database().reference(withPath: "\(path)")
        let path = UserUid.uid
        self.databaseReference = Database.database().reference(withPath: "\(path)").child(veterinariesItem)
    }

    func observeVeterinaries(callback: @escaping (Bool, [VeterinaryItem]) -> Void) {
        self.databaseReference
            .queryOrdered(byChild: "veterinaryName")
            .observe(.value, with: { snapshot in
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

    func getVeterinaryFromKey(veterinaryToSearch: String, callback: @escaping (Bool, String, Int) -> Void) {
        guard veterinariesItems.count != 0 else {
            callback(false, "", -1)
            return
        }
        for indice in 0...veterinariesItems.count-1
            where veterinariesItems[indice].key == veterinaryToSearch {
                callback(true, veterinariesItems[indice].veterinaryName, indice)
        }
        callback(false, "", -1)
    }
}
