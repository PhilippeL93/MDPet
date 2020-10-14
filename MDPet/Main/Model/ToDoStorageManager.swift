//
//  ToDoStorageManager.swift
//  MDPet
//
//  Created by Philippe on 06/10/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class ToDoStorageManager {

    let persistentContainer: NSPersistentContainer!

    lazy var backgroundContext: NSManagedObjectContext = {
        return self.persistentContainer.newBackgroundContext()
    }()

// MARK: Init with dependency
    init(container: NSPersistentContainer) {
        self.persistentContainer = container
        self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }

    convenience init() {
        //Use the default container for production environment
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Can not get shared app delegate")
        }
        self.init(container: appDelegate.persistentContainer)
    }

// MARK: CRUD
    func insertVeterinaryItem( veterinaryToSave: VeterinariesItem ) {

        guard NSEntityDescription.insertNewObject(forEntityName: "VeterinariesItem",
                                                  into: backgroundContext) is VeterinariesItem else {
            return
        }
        save()
    }

    func fetchAll() -> [VeterinariesItem] {
        let request: NSFetchRequest<VeterinariesItem> = VeterinariesItem.fetchRequest()
        let results = try? persistentContainer.viewContext.fetch(request)
        return results ?? [VeterinariesItem]()
    }

    func remove( objectID: NSManagedObjectID ) {
        let obj = backgroundContext.object(with: objectID)
        backgroundContext.delete(obj)
    }

    func save() {
        if backgroundContext.hasChanges {
            do {
                try backgroundContext.save()
            } catch {
                print("Save error \(error)")
            }
        }
    }
}
