//
//  VaccinesListViewController.swift
//  MDPet
//
//  Created by Philippe on 26/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit

class VaccinesListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var petNameLabel: UILabel!

    @IBAction func addNewVaccine(_ sender: UIBarButtonItem) {
        createNewVaccine()
    }
    @IBAction func backToPet(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    // MARK: Properties
    var petItem: PetItem?
    var vaccineItems: [VaccineItem] = []

    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        petNameLabel.text = petItem?.petName
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        GetFirebaseVaccines.shared.observeVaccines(petKey: petItem!.key) { (success, vaccineItems) in
            if success {
                self.vaccineItems = vaccineItems
                self.tableView.reloadData()
            } else {
                print("erreur")
            }
        }
    }
    private func createNewVaccine() {
        guard let destVC = self.storyboard?.instantiateViewController(withIdentifier: "VaccineController")
            as? VaccineViewController else {
                return
        }
        destVC.petItem = petItem
        destVC.typeOfCall = "create"
        self.show(destVC, sender: self)
    }

}
// MARK: - extension Data for tableView
extension VaccinesListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemVaccine", for: indexPath)
            as? PresentVaccineCell else {
                return UITableViewCell()
        }

        let vaccineItem = vaccineItems[indexPath.row]
        cell.configureVaccineCell(with: vaccineItem)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vaccineItems.count
    }
}

// MARK: - extension Delegate
extension VaccinesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let size = tableView.frame.height / 3
        return size
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let destVC = self.storyboard?.instantiateViewController(withIdentifier: "VaccineController")
            as? VaccineViewController else {
                return
        }
        let vaccineItem = vaccineItems[indexPath.row]
        destVC.typeOfCall = "update"
        destVC.petItem = petItem
        destVC.vaccineItem = vaccineItem
        self.show(destVC, sender: self)
    }
}
