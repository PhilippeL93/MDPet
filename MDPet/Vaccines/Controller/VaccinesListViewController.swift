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
    var petItem: PetsItem?
    var vaccinesList = VaccinesItem.fetchAll(vaccinePet: "")

    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        petNameLabel.text = petItem?.petName
        self.navigationItem.title = "Vaccins"
        UINavigationBar.appearance().titleTextAttributes = [
            .font: UIFont(name: "Raleway", size: 17)! ]
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        refresh()
    }
    private func createNewVaccine() {
        guard let destVC = self.storyboard?.instantiateViewController(withIdentifier: "VaccineController")
            as? VaccineViewController else {
                return
        }
        destVC.petItem = petItem
        destVC.typeOfCall = TypeOfCall.create
        self.show(destVC, sender: self)
    }
    @objc private func refresh() {
        vaccinesList = VaccinesItem.fetchAll(vaccinePet: (petItem?.petRecordID)!)
        tableView.reloadData()
    }
}

extension VaccinesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vaccinesList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemVaccine", for: indexPath)
          as? PresentVaccineCell else {
              return UITableViewCell()
      }
        cell.configureVaccineCell(with: vaccinesList[indexPath.row])
        return cell
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
        guard
            let cell = tableView.cellForRow(at: indexPath),
            let indexPath = tableView.indexPath(for: cell)
            else
        { return }
        let vaccineItem = vaccinesList[indexPath.row]
        destVC.typeOfCall = TypeOfCall.update
        destVC.petItem = petItem
        destVC.vaccineItem = vaccineItem
        self.show(destVC, sender: self)
    }
}
