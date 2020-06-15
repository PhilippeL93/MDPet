//
//  VeterinariesListTableViewController.swift
//  MDPet
//
//  Created by Philippe on 02/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit
import Firebase

class VeterinariesListTableViewController: UIViewController {

    @IBOutlet var tableView: UITableView!

    @IBAction func addNewVeterinary(_ sender: UIBarButtonItem) {
        createNewVeterinary()
    }
    // MARK: Constants
    let listToUsers = "ListToUsers"

    // MARK: Properties
    var veterinariesItems: [VeterinaryItem] = []
    var user: User!
    var databaseRef = Database.database().reference(withPath: "veterinaries-item")
    let usersRef = Database.database().reference(withPath: "online")

    // MARK: UIViewController Lifecycle
      override func viewDidLoad() {
        super.viewDidLoad()
        let path = UserUid.uid + "-veterinaries-item"

        databaseRef = Database.database().reference(withPath: "\(path)")

        databaseRef.queryOrdered(byChild: "veterinaryName").observe(.value, with: { snapshot in
          var newItems: [VeterinaryItem] = []
          for child in snapshot.children {
            if let snapshot = child as? DataSnapshot,
              let veterinaryItem = VeterinaryItem(snapshot: snapshot) {
              newItems.append(veterinaryItem)
            }
          }
          self.veterinariesItems = newItems
          self.tableView.reloadData()
        })

        Auth.auth().addStateDidChangeListener { auth, user in
            guard let user = user else { return }
            self.user = User(authData: user)

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
    private func createNewVeterinary() {
        guard let destVC = self.storyboard?.instantiateViewController(withIdentifier: "veterinaryController")
            as? VeterinaryViewController else {
                return
        }
        destVC.typeOfCall = "create"
        self.show(destVC, sender: self)
    }
}

// MARK: - extension Data for tableView
extension VeterinariesListTableViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemVeterinary", for: indexPath)
            as? PresentVeterinaryCell else {
            return UITableViewCell()
        }

        let veterinaryItem = veterinariesItems[indexPath.row]
        cell.cellDelegate = self
        cell.indexSelected = indexPath
        cell.configurePetCell(with: veterinaryItem.veterinaryName, city: veterinaryItem.veterinaryCity)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return veterinariesItems.count
    }
}

// MARK: - extension Delegate
extension VeterinariesListTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let size = tableView.frame.height / 8
        return size
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let destVC = self.storyboard?.instantiateViewController(withIdentifier: "veterinaryController")
            as? VeterinaryViewController else {
                return
        }
        let veterinaryItem = veterinariesItems[indexPath.row]
        destVC.typeOfCall = "update"
        destVC.veterinaryItem = veterinaryItem
        self.show(destVC, sender: self)
    }
}

extension VeterinariesListTableViewController: TableViewClick {
    func onClickCell(index: Int) {
        if let url = URL(string: "telprompt://\(veterinariesItems[index].veterinaryPhone)") {
            let application = UIApplication.shared
            guard application.canOpenURL(url) else {
                return
            }
            application.open(url, options: [:], completionHandler: nil)
        }
    }
}