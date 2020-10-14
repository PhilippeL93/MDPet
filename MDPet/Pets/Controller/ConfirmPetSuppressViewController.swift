//
//  ConfirmPetSuppressViewController.swift
//  MDPet
//
//  Created by Philippe on 15/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit
import CoreData

class ConfirmPetSuppressViewController: UIViewController {

    // MARK: - buttons
    @IBAction func suppressPet(_ sender: UIButton) {
        gestSuppressPet()
        petHasBeenDeleted = true
        prepareToGoBack()
    }
    @IBAction func cancelSuppressPet(_ sender: Any) {
        petHasBeenDeleted = false
        prepareToGoBack()
    }
    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showAnimate()
    }
    // MARK: - var
//    var petObjectId: NSManagedObjectID?
    var petItem: PetsItem?
    var petHasBeenDeleted = true

    // MARK: - functions
    private func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.5, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
        )
    }
    private func removeAnimate() {
        UIView.animate(withDuration: 0.5, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion: {(finished: Bool) in
            if (finished) {
                self.view.removeFromSuperview()
            }
        }
        )
    }
    private func prepareToGoBack() {
        NotificationCenter.default.post(name: .petHasBeenDeleted, object: petHasBeenDeleted)
        NotificationCenter.default.post(name: .navigationBarPetToTrue, object: self)
        self.removeAnimate()
        self.view.removeFromSuperview()
    }
    private func gestSuppressPet() {
        getSuppressVaccines()
        getSuppressConsultations()
        let petToDelete = Model.shared.getObjectByIdPet(objectId: petItem!.objectID )
        AppDelegate.viewContext.delete(petToDelete!)
        try? AppDelegate.viewContext.save()
    }
    private func getSuppressVaccines() {
        let vaccinesList = VaccinesItem.fetchAll(vaccinePet: (petItem?.petRecordID)!)
        guard vaccinesList.count > 0 else {
            return
        }
        VaccinesItem.deleteForPet(vaccinesList: vaccinesList)
    }
    private func getSuppressConsultations() {
        let consultationsList = ConsultationsItem.fetchAll(consultationPet: (petItem?.petRecordID)!)
        guard consultationsList.count > 0 else {
            return
        }
        ConsultationsItem.deleteForPet(consultationsList: consultationsList)
    }
}
