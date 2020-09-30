//
//  PetsListTableViewController.swift
//  MDPet
//
//  Created by Philippe on 02/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit
//import CloudKit

class PetsListTableViewController: UIViewController {

    @IBOutlet var tableView: UITableView!

    @IBAction func addNewPet(_ sender: Any) {
        createNewPet()
    }

    // MARK: Properties
    var petsList = PetsItem.fetchAll()

    // MARK: UIViewController Lifecycle
      override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        refresh()
    }
    private func createNewPet() {
        guard let destVC = self.storyboard?.instantiateViewController(withIdentifier: "PetController")
            as? PetViewController else {
                return
        }
        destVC.typeOfCall = TypeOfCall.create
        self.show(destVC, sender: self)
    }
    @objc private func refresh() {
        petsList = PetsItem.fetchAll()
        tableView.reloadData()
    }
}
extension PetsListTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petsList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemPet", for: indexPath)
          as? PresentPetCell else {
              return UITableViewCell()
      }
        cell.configurePetCell(petsItem: petsList[indexPath.row]) { (success) in
            if !success {
                return
            }
        }
        return cell
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
        let petItem = petsList[indexPath.row]
        destVC.typeOfCall = TypeOfCall.update
        destVC.petItem = petItem
        self.show(destVC, sender: self)
    }
}
