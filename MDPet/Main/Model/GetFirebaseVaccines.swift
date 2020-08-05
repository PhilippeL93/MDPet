//
//  GetFirebaseVaccines.swift
//  MDPet
//
//  Created by Philippe on 26/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

class GetFirebaseVaccines {

    static let shared = GetFirebaseVaccines(with: DatabaseReference())
    private var databaseReference: DatabaseReference
    var imageRef = Storage.storage().reference().child(petsInages)
    var vaccineItems: [VaccineItem] = []
    var newItems: [VaccineItem] = []

    private let localeLanguage = Locale(identifier: "FR-fr")
    private var dateFormatter = DateFormatter()

    init(with databaseReference: DatabaseReference) {
        self.databaseReference = databaseReference
//        let path = UserUid.uid
//        self.databaseReference = Database.database().reference(withPath: "\(path)").child(petsItem)
    }

    func observeVaccines(petKey: String, callback: @escaping (Bool, [VaccineItem]) -> Void) {
        let path = UserUid.uid
        databaseReference = Database.database().reference(withPath: "\(path)").child(petsItem).child(petKey).child(vaccinesItem)
        self.databaseReference
            .queryOrdered(byChild: "vaccineDate")
            .observe(.value, with: { snapshot in
                self.newItems = []
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot,
                        let vaccineItem = VaccineItem(snapshot: snapshot) {
                        self.newItems.append(vaccineItem)
                    }
                }
                if self.newItems.count != 0 {
                    self.newItems = self.newItems.sorted(by: {
                        $0.vaccineDate > $1.vaccineDate
                    })
                }
                self.vaccineItems = self.newItems
                callback(true, self.vaccineItems)
        })
    }
    func readVaccines(petKey: String, veterinaryToSearch: String, callback: @escaping (Bool) -> Void) {
        let path = UserUid.uid
        databaseReference = Database.database().reference(withPath: "\(path)").child(petsItem).child(petKey).child(vaccinesItem)
        var veterinaryFound = false
        self.databaseReference
            .observeSingleEvent(of: .value) {snapshot in
                self.newItems = []
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot,
                        let vaccineItem = VaccineItem(snapshot: snapshot) {
                        if vaccineItem.vaccineVeterinary == veterinaryToSearch {
                            veterinaryFound = true
                        }
                    }
                    callback(veterinaryFound)
                }
        }
    }
    func deleteAllVaccines(petKey: String, callback: @escaping (Bool) -> Void) {
        databaseReference = databaseReference.child(petKey).child(vaccinesItem)
        self.databaseReference
            .observeSingleEvent(of: .value) {snapshot in
                self.newItems = []
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot,
                        let vaccineItem = VaccineItem(snapshot: snapshot) {
                        let vaccineKey = vaccineItem.key
                        if !vaccineItem.vaccineURLThumbnail.isEmpty {
                            let imageDeleteRef = self.imageRef.child("\(petKey ).png")
                            imageDeleteRef.delete { error in
                                if let error = error {
                                    print("error \(error)")
                                }
                            }
                        }
                        let deleteRefVaccine = self.databaseReference.child(vaccineKey)
                        deleteRefVaccine.removeValue()
                    }
                }
                callback(true)
        }
    }
    private func sortTable(wayToSort: String) {
        for indice in 0...newItems.count-1 {
            if wayToSort == "fromDMYToYMD" {
                dateFormatter.dateFormat = "dd MMMM yyyy"
            } else {
                dateFormatter.dateFormat = "yyyyMMdd"
            }
            let dateNewFormat = self.dateFormatter.date(from: newItems[indice].vaccineDate)
            if wayToSort == "fromDMYToYMD" {
                dateFormatter.dateFormat = "yyyyMMdd"
            } else {
                dateFormatter.dateFormat = "dd MMMM yyyy"
            }
            let dateInverted = self.dateFormatter.string(from: dateNewFormat!)
            newItems[indice].vaccineDate = dateInverted
        }
    }
}
