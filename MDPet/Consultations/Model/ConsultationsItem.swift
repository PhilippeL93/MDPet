//
//  ConsultationsItem.swift
//  MDPet
//
//  Created by Philippe on 14/09/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import CoreData

enum ConsultationsItemKey: String {
    case consultationReason
    case consultationDate
    case consultationVeterinary
    case consultationReport
    case consultationWeight
    case consultationIdEvent
    case consultationPet
}
class ConsultationsItem: NSManagedObject {
    static func fetchAll(viewContext: NSManagedObjectContext = AppDelegate.viewContext) -> [ConsultationsItem] {
        let request: NSFetchRequest<ConsultationsItem> = ConsultationsItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "consultationReason", ascending: true)]
        guard let consultationsItem = try? AppDelegate.viewContext.fetch(request) else {
            return []
        }
        return consultationsItem
    }
    static func fetchAll(consultationPet: String,
                         viewContext: NSManagedObjectContext = AppDelegate.viewContext) -> [ConsultationsItem] {
        let request: NSFetchRequest<ConsultationsItem> = ConsultationsItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "consultationReason", ascending: true)]
        request.predicate = NSPredicate(format: "consultationPet = %@", consultationPet)
        guard let consultationsItem = try? AppDelegate.viewContext.fetch(request) else {
            return []
        }
        return consultationsItem
    }
}
