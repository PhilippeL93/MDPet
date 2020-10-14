//
//  ConfirmVaccineSuppressViewController.swift
//  MDPet
//
//  Created by Philippe on 05/08/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit
import CoreData

class ConfirmVaccineSuppressViewController: UIViewController {

    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showAnimate()
    }

    @IBAction func suppressVaccine(_ sender: Any) {
        getSuppressVaccine()
        vaccineHasBeenDeleted = true
        prepareToGoBack()
    }
    @IBAction func cancelSuppressVaccine(_ sender: Any) {
        vaccineHasBeenDeleted = false
        prepareToGoBack()
    }

    // MARK: - var
    var vaccineObjectId: NSManagedObjectID?
    var vaccineHasBeenDeleted = true

    // MARK: - functions
        ///   showAnimate in order animate pollutants view when it's apperaed
    private func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.5, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    private func removeAnimate() {
        UIView.animate(withDuration: 0.5, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion: {(finished: Bool) in
            if (finished) {
                self.view.removeFromSuperview()
            }
        })
    }
    private func prepareToGoBack() {
        NotificationCenter.default.post(name: .vaccineHasBeenDeleted, object: vaccineHasBeenDeleted)
        NotificationCenter.default.post(name: .navigationBarVaccineToTrue, object: self)
        self.removeAnimate()
        self.view.removeFromSuperview()
    }
    private func getSuppressVaccine() {
        let vaccineToDelete = Model.shared.getObjectByIdVaccine(objectId: vaccineObjectId!)
        AppDelegate.viewContext.delete(vaccineToDelete!)
        try? AppDelegate.viewContext.save()
    }
}
