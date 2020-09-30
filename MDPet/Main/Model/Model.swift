//
//  Model.swift
//  MDPet
//
//  Created by Philippe on 09/09/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

class Model {

    static let shared = Model()
  // MARK: - iCloud Info
  let container: CKContainer
  let publicDB: CKDatabase
  let privateDB: CKDatabase

  // MARK: - Properties
    var veterinariesList = VeterinariesItem.fetchAll()
    private(set) var petsItem: [PetsItem] = []
    private(set) var veterinariesItem: [VeterinariesItem] = []
    private(set) var consultationsItem: [ConsultationsItem] = []
    var veterinaryItem: VeterinariesItem?
    static var currentModel = Model()

    init() {
        container = CKContainer.default()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
    }

    func getObjectByIdPet(objectId: NSManagedObjectID) -> PetsItem? {
        return AppDelegate.viewContext.object(with: objectId) as? PetsItem
    }
    func getObjectByIdVeterinary(objectId: NSManagedObjectID) -> VeterinariesItem? {
        return AppDelegate.viewContext.object(with: objectId) as? VeterinariesItem
    }
    func getObjectByIdVaccine(objectId: NSManagedObjectID) -> VaccinesItem? {
        return AppDelegate.viewContext.object(with: objectId) as? VaccinesItem
    }
    func getObjectByIdConsultation(objectId: NSManagedObjectID) -> ConsultationsItem? {
        return AppDelegate.viewContext.object(with: objectId) as? ConsultationsItem
    }
    func getVeterinaryFromRecordID(veterinaryToSearch: String,
                                   completion: @escaping (Bool, VeterinariesItem?) -> Void) {
        let veterinariesList = VeterinariesItem.fetchAll()
        guard veterinariesList.count != 0 else {
            completion(false, nil)
            return
        }
        for indice in 0...veterinariesList.count-1
            where veterinariesList[indice].veterinaryRecordID == veterinaryToSearch {
                completion(true, veterinariesList[indice])
                return
        }
        completion(false, nil)
    }
    func getVeterinaryFromObjectID(veterinaryToSearch: NSManagedObjectID, completion: @escaping (Bool, Int) -> Void) {
        let veterinariesList = VeterinariesItem.fetchAll()
        guard veterinariesList.count != 0 else {
            completion(false, 0)
            return
        }
        for indice in 0...veterinariesList.count-1
            where veterinariesList[indice].objectID == veterinaryToSearch {
                completion(true, indice)
                return
        }
        completion(false, 0)
    }
}
