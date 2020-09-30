//
//  VeterinariesListTableViewController.swift
//  MDPet
//
//  Created by Philippe on 02/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit
//import CloudKit

class VeterinariesListTableViewController: UIViewController {

    @IBOutlet var tableView: UITableView!

    @IBAction func addNewVeterinary(_ sender: UIBarButtonItem) {
        createNewVeterinary()
    }

    // MARK: Properties
    var veterinariesList = VeterinariesItem.fetchAll()

    // MARK: UIViewController Lifecycle
      override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        refresh()
    }
    private func createNewVeterinary() {
        guard let destVC = self.storyboard?.instantiateViewController(withIdentifier: "VeterinaryController")
            as? VeterinaryViewController else {
                return
        }
        destVC.typeOfCall = TypeOfCall.create
        self.show(destVC, sender: self)
    }
    @objc private func refresh() {
        veterinariesList = VeterinariesItem.fetchAll()
        tableView.reloadData()
    }
}

extension VeterinariesListTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return veterinariesList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemVeterinary", for: indexPath)
          as? PresentVeterinaryCell else {
              return UITableViewCell()
      }
        cell.cellDelegate = self
        cell.configureVeterinaryCell(veterinariesItem: veterinariesList[indexPath.row])
        return cell
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
        let veterinaryItem = veterinariesList[indexPath.row]
        destVC.typeOfCall = TypeOfCall.update
        destVC.veterinaryItem = veterinaryItem
        self.show(destVC, sender: self)
    }
}

extension VeterinariesListTableViewController: TableViewClick {
    func onClickCell(phoneNumber: String) {
        if let url = URL(string: "telprompt://\(phoneNumber)") {
            let application = UIApplication.shared
            guard application.canOpenURL(url) else {
                return
            }
            application.open(url, options: [:], completionHandler: nil)
        }
    }
}
