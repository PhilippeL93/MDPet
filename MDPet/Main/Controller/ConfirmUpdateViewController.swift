//
//  ConfirmUpdateViewController.swift
//  MDPet
//
//  Created by Philippe on 16/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit

class ConfirmUpdateViewController: UIViewController {

    @IBAction func cancelUpdate(_ sender: UIButton) {
        isToUpdate = false
        prepareToGoBack()
    }
    @IBAction func continueUpdate(_ sender: UIButton) {
        isToUpdate = true
        prepareToGoBack()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showAnimate()
    }
    var isToUpdate = true
    var petOrVeterinary = ""

// MARK: - functions
        ///   showAnimate in order animate pollutants view when it's apperaed
    private func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.5, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
        )
    }

    ///   removeAnimate in order animate pollutants view when it's disapperaed
    private func removeAnimate() {
        UIView.animate(withDuration: 0.5, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0}, completion: {(finished: Bool) in
                if (finished) {
                    self.view.removeFromSuperview()
                }
        }
        )
    }
    private func prepareToGoBack() {
        if petOrVeterinary == "veterinary" {
            NotificationCenter.default.post(name: .navigationBarVeterinaryToTrue,
                                            object: "navigationBarVeterinaryToTrue")
        }
        if petOrVeterinary == "pet" {
            NotificationCenter.default.post(name: .navigationBarPetToTrue,
                                            object: "navigationBarPetToTrue")
        }
        if petOrVeterinary == "vaccine" {
            NotificationCenter.default.post(name: .navigationBarPetToTrue,
                                            object: "navigationBarVaccineToTrue")
        }
        NotificationCenter.default.post(name: .isToUpdate, object: isToUpdate)
        self.removeAnimate()
        self.view.removeFromSuperview()
    }
}
