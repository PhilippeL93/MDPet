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
    var typeOfCaller: TypeOfCaller?

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
        switch typeOfCaller {
        case .veterinary:
            NotificationCenter.default.post(name: .navigationBarVeterinaryToTrue,
                                            object: "navigationBarVeterinaryToTrue")
                        NotificationCenter.default.post(name: .veterinaryIsToUpdate, object: isToUpdate)
        case .pet:
            NotificationCenter.default.post(name: .navigationBarPetToTrue,
                                            object: "navigationBarPetToTrue")
            NotificationCenter.default.post(name: .petIsToUpdate, object: isToUpdate)
        case .vaccine:
            NotificationCenter.default.post(name: .navigationBarVaccineToTrue,
                                            object: "navigationBarVaccineToTrue")
            NotificationCenter.default.post(name: .vaccineIsToUpdate, object: isToUpdate)
        case .consultation:
            NotificationCenter.default.post(name: .navigationBarConsultationToTrue,
                                            object: "navigationBarConsultationToTrue")
            NotificationCenter.default.post(name: .consultationIsToUpdate, object: isToUpdate)
        case .none:
            print("error")
        }
        self.removeAnimate()
        self.view.removeFromSuperview()
    }
}
