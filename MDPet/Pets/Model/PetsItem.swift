//
//  PetsItem.swift
//  MDPet
//
//  Created by Philippe on 09/09/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import CoreData

enum PetsItemKey: String {
    case petName
    case petPicture
    case petType
    case petGender
    case petBirthDate
    case petTatoo
    case petSterilized
    case petSterilizedDate
    case petVeterinary
    case petRace
    case petWeaning
    case petWeaningDate
    case petDeathDate
    case petColor
    case petBreeder
    case petURLBreeder
    case petParticularSigns
    case petPedigree
    case petPedigreeNumber
    case petMotherName
    case petFatherName
    case petRecordID
}
class PetsItem: NSManagedObject {
    static func fetchAll(viewContext: NSManagedObjectContext = AppDelegate.viewContext) -> [PetsItem] {
        let request: NSFetchRequest<PetsItem> = PetsItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "petName", ascending: true)]
        guard let petsItem = try? AppDelegate.viewContext.fetch(request) else {
            return []
        }
        return petsItem
    }
}
