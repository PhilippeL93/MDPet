//
//  AppDelegate.swift
//  MDPet
//
//  Created by Philippe on 29/11/2019.
//  Copyright © 2019 Philippe. All rights reserved.
//

import UIKit
import CloudKit
import CoreData

extension UIViewController {

    var container: CKContainer {
        return CKContainer(identifier: "iCloud.com.philippe.MDPet")
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var container: CKContainer {
        return CKContainer(identifier: "iCloud.com.philippe.MDPet")
    }

    lazy var persistentContainer: NSPersistentCloudKitContainer = {

        let container = NSPersistentCloudKitContainer(name: "MDPet")

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy

        return container
    }()

    static var persistentContainer: NSPersistentContainer {
        // swiftlint:disable force_cast
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        // swiftlint:enable force_cast
    }

    static var viewContext: NSManagedObjectContext {
        let viewContext = persistentContainer.viewContext
        viewContext.automaticallyMergesChangesFromParent = true
        return viewContext
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        configureCloudKit()
        accountStatus()
        return true
    }

    private func configureCloudKit() {
        let container = CKContainer(identifier: "iCloud.com.philippe.MDPet")

        container.publicCloudDatabase.fetchAllRecordZones { zones, error in
            guard let zones = zones, error == nil else {
                // error handling magic
                return
            }
            print("I have these zones: \(zones)")
        }
    }
    private func accountStatus() {
        container.accountStatus { status, error in
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if error != nil {
                    let controller = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                    self.window?.rootViewController = controller
                    self.window?.makeKeyAndVisible()
                } else {
                    switch status {
                    case .available:
                        let controller = storyboard.instantiateViewController(withIdentifier: "LoginToList")
                        self.window?.rootViewController = controller
                        self.window?.makeKeyAndVisible()
                    case .couldNotDetermine, .noAccount, .restricted:
                        let controller = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                        self.window?.rootViewController = controller
                        self.window?.makeKeyAndVisible()
                    @unknown default:
                        fatalError()
                    }
                }
            }
        }
    }
}
