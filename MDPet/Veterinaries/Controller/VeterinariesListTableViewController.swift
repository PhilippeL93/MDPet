//
//  VeterinariesListTableViewController.swift
//  MDPet
//
//  Created by Philippe on 02/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit
import Firebase

class VeterinariesListTableViewController: UITableViewController {

    // MARK: Constants
    let listToUsers = "ListToUsers"

    // MARK: Properties
    var items: [VeterinaryItem] = []
    var user: User!
    var databaseRef = Database.database().reference(withPath: "veterinay-tems")
    let usersRef = Database.database().reference(withPath: "online")

    // MARK: UIViewController Lifecycle
      override func viewDidLoad() {
        super.viewDidLoad()

        Auth.auth().addStateDidChangeListener { auth, user in
            guard let user = user else { return }
            self.user = User(authData: user)
            self.databaseRef = Database.database().reference(withPath: "\(user.uid)")
            let currentUserRef = self.usersRef.child(self.user.uid)
            currentUserRef.setValue(self.user.email)
            currentUserRef.onDisconnectRemoveValue()
        }
    }
}
