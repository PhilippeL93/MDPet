//
//  VeterinariesItem.swift
//  MDPet
//
//  Created by Philippe on 11/09/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import CoreData

enum VeterinariesItemKey: String {
    case veterinaryName
    case clinicSwitch
    case clinicName
    case veterinaryFirstName
    case veterinaryStreetOne
    case veterinaryStreetTwo
    case veterinaryPostalCode
    case veterinaryCity
    case veterinaryPhone
    case veterinaryEmail
    case veterinaryNumber
    case veterinaryRecordID
}

class VeterinariesItem: NSManagedObject {
    static func fetchAll(viewContext: NSManagedObjectContext = AppDelegate.viewContext) -> [VeterinariesItem] {
        let request: NSFetchRequest<VeterinariesItem> = VeterinariesItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "veterinaryName", ascending: true)]
        guard let veterinariesItem = try? AppDelegate.viewContext.fetch(request) else {
            return []
        }
        return veterinariesItem
    }
}
