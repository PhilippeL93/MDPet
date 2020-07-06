//
//  ConsultationsListViewController.swift
//  MDPet
//
//  Created by Philippe on 18/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit

class ConsultationsListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var petNameLabel: UILabel!

    @IBAction func backToPet(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func addNewConsultation(_ sender: Any) {
    }

    // MARK: Properties
    var petItem: PetItem?
    var consultationItems: [ConsultationItem] = []

    // MARK: UIViewController Lifecycle
      override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        GetFirebaseConsultations.shared.observeConsultations { (success, consultationItems) in
            if success {
                self.consultationItems = consultationItems
                self.tableView.reloadData()
            } else {
                print("erreur")
            }
        }
    }
}

// MARK: - extension Data for tableView
extension ConsultationsListViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemConsultation", for: indexPath)
            as? PresentConsultationCell else {
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
extension ConsultationsListViewController: UITableViewDelegate {
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
