//
//  PetsListTableViewController.swift
//  MDPet
//
//  Created by Philippe on 02/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit
import Firebase

class PetsListTableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    // MARK: Constants
    let listToUsers = "ListToUsers"

    // MARK: Properties
    var items: [PetItem] = []
    var user: User!
    var databaseRef = Database.database().reference(withPath: "pets-items")
    let usersRef = Database.database().reference(withPath: "online")

    // MARK: UIViewController Lifecycle
      override func viewDidLoad() {
        super.viewDidLoad()

        databaseRef.queryOrdered(byChild: "petBirthDate").observe(.value, with: { snapshot in
          var newItems: [PetItem] = []
          for child in snapshot.children {
            if let snapshot = child as? DataSnapshot,
              let petItem = PetItem(snapshot: snapshot) {
              newItems.append(petItem)
            }
          }

          self.items = newItems
          self.tableView.reloadData()
        })

        Auth.auth().addStateDidChangeListener { auth, user in
            guard let user = user else { return }
            self.user = User(authData: user)
//            self.databaseRef = Database.database().reference(withPath: "\(user.uid)")
            let currentUserRef = self.usersRef.child(self.user.uid)
            currentUserRef.setValue(self.user.email)
            currentUserRef.onDisconnectRemoveValue()
        }
        usersRef.observe(.value, with: { snapshot in
//          if snapshot.exists() {
//            self.userCountBarButtonItem?.title = snapshot.childrenCount.description
//          } else {
//            self.userCountBarButtonItem?.title = "0"
//          }
        })
    }
}

// MARK: - extension Data for tableView
extension PetsListTableViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemPet", for: indexPath)
        let petItem = items[indexPath.row]

        cell.textLabel?.text = petItem.petName
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
}

// MARK: - extension Delegate
extension PetsListTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let size = tableView.frame.height / 6
        return size
    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let cell = tableView.cellForRow(at: indexPath) else { return }
//        let petItem = petItems[indexPath.row]
//        let petName = !petItems.petN
//        toggleCellCheckbox(cell, isCompleted: toggledCompletion)
//        petItem.ref?.updateChildValues([
//            "completed": toggledCompletion
//        ])
//    }
}
