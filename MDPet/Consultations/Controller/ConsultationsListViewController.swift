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
         createNewConsultation()
    }

    // MARK: Properties
    var petItem: PetsItem?
    var consultationsList = ConsultationsItem.fetchAll(consultationPet: "")

    // MARK: UIViewController Lifecycle
      override func viewDidLoad() {
        super.viewDidLoad()
        petNameLabel.text = petItem?.petName
        self.navigationItem.title = "Consultations"
        UINavigationBar.appearance().titleTextAttributes = [
            .font: UIFont(name: "Raleway", size: 17)! ]
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        refresh()
    }
    private func createNewConsultation() {
        guard let destVC = self.storyboard?.instantiateViewController(withIdentifier: "ConsultationController")
            as? ConsultationViewController else {
                return
        }
        destVC.petItem = petItem
        destVC.typeOfCall = TypeOfCall.create
        self.show(destVC, sender: self)
    }
    @objc private func refresh() {
        consultationsList = ConsultationsItem.fetchAll(consultationPet: (petItem?.petRecordID)!)
        tableView.reloadData()
    }
}
extension ConsultationsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return consultationsList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemConsultation", for: indexPath)
          as? PresentConsultationCell else {
              return UITableViewCell()
      }
        cell.configureConsultationCell(consultationItem: consultationsList[indexPath.row]) { (success) in
            if !success {
                return
            }
        }
        return cell
    }
}

// MARK: - extension Delegate
extension ConsultationsListViewController: UITableViewDelegate {
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            let size = tableView.frame.height / 8
            return size
        }
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            guard let destVC = self.storyboard?.instantiateViewController(withIdentifier: "ConsultationController")
                as? ConsultationViewController else {
                    return
            }
            guard
                let cell = tableView.cellForRow(at: indexPath),
                let indexPath = tableView.indexPath(for: cell)
                else
            { return }
            let consultationItem = consultationsList[indexPath.row]
            destVC.typeOfCall = TypeOfCall.update
            destVC.petItem = petItem
            destVC.consultationItem = consultationItem
            self.show(destVC, sender: self)
        }
}
