//
//  VeterinariesListTableViewController.swift
//  MDPet
//
//  Created by Philippe on 02/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit
import FirebaseDatabase

class VeterinariesListTableViewController: UIViewController {

    @IBOutlet var tableView: UITableView!

    @IBAction func addNewVeterinary(_ sender: UIBarButtonItem) {
        createNewVeterinary()
    }

    // MARK: Properties
    var veterinariesItems: [VeterinaryItem] = []

    // MARK: UIViewController Lifecycle
      override func viewDidLoad() {
        super.viewDidLoad()
        GetFirebaseVeterinaries.shared.observeVeterinaries { (success, veterinariesItems) in
            if success {
                self.veterinariesItems = veterinariesItems
                self.tableView.reloadData()
            } else {
                print("erreur")
            }
        }
    }
    private func createNewVeterinary() {
        guard let destVC = self.storyboard?.instantiateViewController(withIdentifier: "VeterinaryController")
            as? VeterinaryViewController else {
                return
        }
        destVC.typeOfCall = TypeOfCall.create
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
        cell.configurePetCell(with: veterinaryItem.veterinaryName,
                              city: veterinaryItem.veterinaryCity,
                              phone: veterinaryItem.veterinaryPhone)
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
        guard let destVC = self.storyboard?.instantiateViewController(withIdentifier: "VeterinaryController")
            as? VeterinaryViewController else {
                return
        }
        let veterinaryItem = veterinariesItems[indexPath.row]
        destVC.typeOfCall = TypeOfCall.update
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
