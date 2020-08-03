//
//  FirebaseDatabaseClient.swift
//  MDPet
//
//  Created by Philippe on 03/08/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FirebaseDatabaseClient {

    private let databaseReference: DatabaseReference
    var veterinariesItems: [VeterinaryItem] = []

    init(with databaseReference: DatabaseReference) {
        self.databaseReference = databaseReference
    }

    func readSample(completion: @escaping ([String]) -> Void) {
        self.databaseReference
            .child("sample")
            .observeSingleEvent(of: .value) { snapshot in
                var sampleList: [String] = []
                // ...
                completion(sampleList)
        }
    }

    func observeVeterinaries(callback: @escaping (Bool, [VeterinaryItem]) -> Void) {
        self.databaseReference
            .queryOrdered(byChild: "veterinaryName")
            .observeSingleEvent(of: .value) {snapshot in
                var newItems: [VeterinaryItem] = []
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot,
                        let veterinaryItem = VeterinaryItem(snapshot: snapshot) {
                        newItems.append(veterinaryItem)
                    }
                }
                self.veterinariesItems = newItems
                callback(true, self.veterinariesItems)
        }
    }
}
