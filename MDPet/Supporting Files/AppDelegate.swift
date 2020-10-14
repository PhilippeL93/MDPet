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

//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
        container.loadPersistentStores(completionHandler: { (_, error) in
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
    func applicationWillResignActive(_ application: UIApplication) {
// Sent when the application is about to move from active to inactive state.
// This can occur for certain types of temporary interruptions (such as an incoming phone call
// or SMS message) or when the user quits the application and it begins the transition to the background state.
// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks.
// Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
// Use this method to release shared resources, save user data, invalidate timers,
// and store enough application state information to restore your application to its current state
// in case it is terminated later.
// If your application supports background execution, this method is called instead of
// applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
// Called as part of the transition from the background to the active state;
// here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
// Restart any tasks that were paused (or not yet started) while the application was inactive.
// If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }

    // MARK: - Core Data Saving support
    private func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    private func configureCloudKit() {
        let container = CKContainer(identifier: "iCloud.com.philippe.MDPet")

        container.privateCloudDatabase.fetchAllRecordZones { zones, error in
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
