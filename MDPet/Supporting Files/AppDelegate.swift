//
//  AppDelegate.swift
//  MDPet
//
//  Created by Philippe on 29/11/2019.
//  Copyright © 2019 Philippe. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseCore
import FirebaseAuth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    override init() {
        super.init()
//        print("================== AppDelegate init")
        FirebaseApp.configure()
//        print("================= AppDelegate \(FirebaseApp.app()) ")
        Database.database().isPersistenceEnabled = true
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//      FirebaseApp.configure()
//        print("================== AppDelegate application")
        Database.database().isPersistenceEnabled = true
        _ = Auth.auth().addStateDidChangeListener { _, user in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if user != nil {
                print("====================== AppDelegate user != nil")
                let controller = storyboard.instantiateViewController(withIdentifier: "LoginToList")
                self.window?.rootViewController = controller
                self.window?.makeKeyAndVisible()
                UserUid.uid = user!.uid
            } else {
                print("====================== AppDelegate else user != nil")
                let controller = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                self.window?.rootViewController = controller
                self.window?.makeKeyAndVisible()
            }
        }
        return true
    }
}
