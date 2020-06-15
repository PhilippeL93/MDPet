//
//  ConfirmVeterinarySuppressViewController.swift
//  MDPet
//
//  Created by Philippe on 15/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let navigationBarVeterinaryToTrue = Notification.Name("navigationBarVeterinaryToTrue")
}

class ConfirmVeterinarySuppressViewController: UIViewController {

    @IBAction func suppressVeterinary(_ sender: UIButton) {
        gestSuppressVeterinary()
        NotificationCenter.default.post(name: .navigationBarVeterinaryToTrue, object: self)
        self.removeAnimate()
        self.view.removeFromSuperview()
    }

    @IBAction func cancelSuppressVeterinary(_ sender: UIButton) {
        NotificationCenter.default.post(name: .navigationBarVeterinaryToTrue, object: self)
        self.removeAnimate()
        self.view.removeFromSuperview()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.showAnimate()
    }

    var veterinaryKey: String = ""

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
    private func gestSuppressVeterinary() {

    }
}
