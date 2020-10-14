//
//  VaccinesItem.swift
//  MDPet
//
//  Created by Philippe on 14/09/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import CoreData

enum VaccinesItemKey: String {
    case vaccineInjection
    case vaccineName
    case vaccineDate
    case vaccineThumbnail
    case vaccineVeterinary
    case vaccineDiseases
    case vaccineSwitchDiseases
    case vaccineDone
    case vaccinePet
}

class VaccinesItem: NSManagedObject {
    static func fetchAll(viewContext: NSManagedObjectContext = AppDelegate.viewContext) -> [VaccinesItem] {
        let request: NSFetchRequest<VaccinesItem> = VaccinesItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "vaccineName", ascending: true)]
        guard let vaccinesItem = try? AppDelegate.viewContext.fetch(request) else {
            return []
        }
        return vaccinesItem
    }
    static func fetchAll(vaccinePet: String,
                         viewContext: NSManagedObjectContext = AppDelegate.viewContext) -> [VaccinesItem] {
        let request: NSFetchRequest<VaccinesItem> = VaccinesItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "vaccineName", ascending: true)]
        request.predicate = NSPredicate(format: "vaccinePet = %@", vaccinePet)
        guard let vaccinesItem = try? AppDelegate.viewContext.fetch(request) else {
            return []
        }
        return vaccinesItem
    }
    static func deleteForPet(vaccinesList: [VaccinesItem],
                             viewContext: NSManagedObjectContext = AppDelegate.viewContext) {
        for indice in 0...vaccinesList.count - 1 {
            let vaccineToDelete = Model.shared.getObjectByIdVaccine(objectId: vaccinesList[indice].objectID )
            AppDelegate.viewContext.delete(vaccineToDelete!)
            try? AppDelegate.viewContext.save()
        }
    }
}
