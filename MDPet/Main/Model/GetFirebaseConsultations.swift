//
//  GetFirebaseConsultations.swift
//  MDPet
//
//  Created by Philippe on 02/07/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import Foundation
import FirebaseDatabase

class GetFirebaseConsultations {

    static let shared = GetFirebaseConsultations(with: DatabaseReference())
    private var databaseReference: DatabaseReference
    var consultationItems: [ConsultationItem] = []
    var newItems: [ConsultationItem] = []

    init(with databaseReference: DatabaseReference) {
        self.databaseReference = databaseReference
//        let path = UserUid.uid
//        self.databaseReference = Database.database().reference(withPath: "\(path)").child(petsItem)
    }

    private let localeLanguage = Locale(identifier: "FR-fr")
    private var dateFormatter = DateFormatter()

    func observeConsultations(petKey: String, callback: @escaping (Bool, [ConsultationItem]) -> Void) {
        let path = UserUid.uid
        databaseReference = Database.database().reference(withPath:
            "\(path)").child(petsItem).child(petKey).child(consultationsItem)
        self.databaseReference
            .queryOrdered(byChild: "consultationDate")
            .observe(.value, with: { snapshot in
                self.newItems = []
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot,
                        let consultationItem = ConsultationItem(snapshot: snapshot) {
                        self.newItems.append(consultationItem)
                    }
                }
                if self.newItems.count != 0 {
                    self.newItems = self.newItems.sorted(by: {
                        $0.consultationDate > $1.consultationDate
                    })
                }
                self.consultationItems = self.newItems
                callback(true, self.consultationItems)
        })
    }
    func readConsultations(petKey: String, veterinaryToSearch: String, callback: @escaping (Bool) -> Void) {
        let path = UserUid.uid
        databaseReference = Database.database().reference(withPath:
            "\(path)").child(petsItem).child(petKey).child(consultationsItem)
        var veterinaryFound = false
        self.databaseReference
            .observeSingleEvent(of: .value) {snapshot in
                self.newItems = []
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot,
                        let consultationItem = ConsultationItem(snapshot: snapshot) {
                        if consultationItem.consultationVeterinary == veterinaryToSearch {
                            veterinaryFound = true
                        }
                    }
                }
                callback(veterinaryFound)
        }
    }
    func deleteConsultation(petKey: String, consultationKey: String, callback: @escaping (Bool) -> Void) {
        let path = UserUid.uid
        databaseReference = Database.database().reference(withPath:
            "\(path)").child(petsItem).child(petKey).child(consultationsItem).child(consultationKey)
        self.databaseReference
            .removeValue()
    }
    private func sortTable(wayToSort: String) {
        for indice in 0...newItems.count-1 {
            if wayToSort == "fromDMAToAMD" {
//                dateFormatter.dateFormat = "dd MMMM yyyy"
                dateFormatter.dateFormat = dateFormatddMMMMyyyyWithSpaces
            } else {
//                dateFormatter.dateFormat = "yyyyMMdd"
                dateFormatter.dateFormat = dateFormatyyyyMMdd
            }
            let dateNewFormat = self.dateFormatter.date(from: newItems[indice].consultationDate)
            if wayToSort == "fromDMAToAMD" {
//                dateFormatter.dateFormat = "yyyyMMdd"
                dateFormatter.dateFormat = dateFormatyyyyMMdd
            } else {
//                dateFormatter.dateFormat = "dd MMMM yyyy"
                dateFormatter.dateFormat = dateFormatddMMMMyyyyWithSpaces
            }
            let dateInverted = self.dateFormatter.string(from: dateNewFormat!)
            newItems[indice].consultationDate = dateInverted
        }
    }
}
