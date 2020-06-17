//
//  ConfirmPetSuppressViewController.swift
//  MDPet
//
//  Created by Philippe on 15/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit

//extension Notification.Name {
//    static let navigationBarPetToTrue = Notification.Name("navigationBarPetToTrue")
//}

class ConfirmPetSuppressViewController: UIViewController {

    @IBAction func suppressPet(_ sender: UIButton) {
        gestSuppressPet()
        NotificationCenter.default.post(name: .navigationBarPetToTrue, object: self)
        self.removeAnimate()
        self.view.removeFromSuperview()
    }

    @IBAction func cancelSuppressPet(_ sender: Any) {
                NotificationCenter.default.post(name: .navigationBarPetToTrue, object: self)
                self.removeAnimate()
                self.view.removeFromSuperview()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.showAnimate()
    }
    var petKey: String = ""

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
            self.view.alpha = 0.0
        }, completion: {(finished: Bool) in
            if (finished) {
                self.view.removeFromSuperview()
            }
        }
        )
    }
    private func gestSuppressPet() {
        
    }
}
