//
//  VaccinesListTableViewController.swift
//  MDPet
//
//  Created by Philippe on 18/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit

class VaccinesListTableViewController: UIViewController {

}
// MARK: - extension Data for tableView
extension VaccinesListTableViewController: UITableViewDataSource {
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemPet", for: indexPath)
                as? PresentPetCell else {
                    return UITableViewCell()
            }

    //        let petItem = items[indexPath.row]
    //        cell.configurePetCell(name: petItem.petName,
    //                              URLPicture: petItem.petURLPicture,
    //                              birthDate: petItem.petBirthDate) { (success) in
    //                                if !success {
    //                                    return
    //                                }
    //        }
            return cell
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //        return items.count
            return 1
        }
}

// MARK: - extension Delegate
extension VaccinesListTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let size = tableView.frame.height / 8
        return size
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let destVC = self.storyboard?.instantiateViewController(withIdentifier: "veterinaryController")
//            as? VeterinaryViewController else {
//                return
//        }
//        let veterinaryItem = veterinariesItems[indexPath.row]
//        destVC.typeOfCall = "update"
//        destVC.veterinaryItem = veterinaryItem
//        self.show(destVC, sender: self)
    }
}
