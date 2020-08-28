//
//  ConfirmVaccineSuppressViewController.swift
//  MDPet
//
//  Created by Philippe on 05/08/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit

class ConfirmVaccineSuppressViewController: UIViewController {

    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showAnimate()
    }

    @IBAction func suppressVaccine(_ sender: Any) {
        getSuppressVaccine()
        prepareToGoBack()
    }
    @IBAction func cancelSuppressVaccine(_ sender: Any) {
        vaccineHasBeenDeleted = false
        prepareToGoBack()
    }

    // MARK: - var
    var petItem: PetItem?
    var vaccineItem: VaccineItem?
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

        let vaccineKey = vaccineItem?.key
        let petKey = petItem?.key

        GetFirebaseVaccines.shared.deleteVaccine(petKey: petKey!,
                                                 vaccineKey: vaccineKey!) { (success) in
            if success {
                self.vaccineHasBeenDeleted = true
            } else {
                print("erreur")
            }
        }
    }
}