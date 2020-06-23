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

    @IBAction func addNewPet(_ sender: UIBarButtonItem) {
        createNewPet()
    }
    // MARK: Constants
    let listToUsers = "ListToUsers"

    // MARK: Properties
    var petItems: [PetItem] = []
    var user: User!
    var databaseRef = Database.database().reference(withPath: "pets-item")
    let usersRef = Database.database().reference(withPath: "online")

    // MARK: UIViewController Lifecycle
      override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        let path = UserUid.uid + "-pets-item"

        databaseRef = Database.database().reference(withPath: "\(path)")

        databaseRef.queryOrdered(byChild: "petBirthDate").observe(.value, with: { snapshot in
            var newItems: [PetItem] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                    let petItem = PetItem(snapshot: snapshot) {
                    newItems.append(petItem)
                }
            }
            self.petItems = newItems
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
    private func createNewPet() {
        guard let destVC = self.storyboard?.instantiateViewController(withIdentifier: "newPetController")
            as? NewPetViewController else {
                //        guard let destVC = self.storyboard?.instantiateViewController(withIdentifier: "petController")
                //            as? PetViewController else {
                return
        }
        destVC.typeOfCall = "create"
        self.show(destVC, sender: self)
    }
}

// MARK: - extension Data for tableView
extension PetsListTableViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemPet", for: indexPath)
            as? PresentPetCell else {
                return UITableViewCell()
        }

        let petItem = petItems[indexPath.row]
        cell.configurePetCell(name: petItem.petName,
                              URLPicture: petItem.petURLPicture,
                              birthDate: petItem.petBirthDate) { (success) in
                                if !success {
                                    return
                                }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petItems.count
    }
}

// MARK: - extension Delegate
extension PetsListTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let size = tableView.frame.height / 8
        return size
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let destVC = self.storyboard?.instantiateViewController(withIdentifier: "newPetController")
                    as? NewPetViewController else {
//        guard let destVC = self.storyboard?.instantiateViewController(withIdentifier: "petController")
//            as? PetViewController else {
                return
        }
        let petItem = petItems[indexPath.row]
        destVC.typeOfCall = "update"
        destVC.petItem = petItem
        self.show(destVC, sender: self)
    }
}
