//
//  PetsListTableViewController.swift
//  MDPet
//
//  Created by Philippe on 02/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit

class PetsListTableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    @IBAction func addNewPet(_ sender: UIBarButtonItem) {
        createNewPet()
    }
    // MARK: Constants
    let listToUsers = "ListToUsers"

    // MARK: Properties
    var petItems: [PetItem] = []

    // MARK: UIViewController Lifecycle
      override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        GetFirebasePets.shared.observePets { (success, petItems) in
            if success {
                self.petItems = petItems
                self.tableView.reloadData()
            } else {
                print("erreur")
            }
        }
    }
    private func createNewPet() {
        guard let destVC = self.storyboard?.instantiateViewController(withIdentifier: "PetController")
            as? PetViewController else {
                return
        }
        destVC.typeOfCall = TypeOfCall.create
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
        guard let destVC = self.storyboard?.instantiateViewController(withIdentifier: "PetController")
                    as? PetViewController else {
                return
        }
        let petItem = petItems[indexPath.row]
        destVC.typeOfCall = TypeOfCall.update
        destVC.petItem = petItem
        self.show(destVC, sender: self)
    }
}
