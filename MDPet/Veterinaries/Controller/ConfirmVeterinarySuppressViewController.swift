//
//  ConfirmVeterinarySuppressViewController.swift
//  MDPet
//
//  Created by Philippe on 15/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit
import Firebase

class ConfirmVeterinarySuppressViewController: UIViewController {

    // MARK: - buttons
    @IBAction func suppressVeterinary(_ sender: UIButton) {
        hasBeenDeleted = true
        gestSuppressVeterinary()
        prepareToGoBack()
    }

    @IBAction func cancelSuppressVeterinary(_ sender: UIButton) {
        hasBeenDeleted = false
        prepareToGoBack()
    }

    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showAnimate()
    }

    // MARK: - var
    var veterinaryKey: String = ""
    var databaseRef = Database.database().reference(withPath: "veterinaries-item")
    var hasBeenDeleted = true

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
        NotificationCenter.default.post(name: .hasBeenDeleted, object: hasBeenDeleted)
        NotificationCenter.default.post(name: .navigationBarVeterinaryToTrue, object: self)
        self.removeAnimate()
        self.view.removeFromSuperview()
    }
    private func gestSuppressVeterinary() {
        let path = UserUid.uid + "-veterinaries-item"
        databaseRef = Database.database().reference(withPath: "\(path)")
        let deleteRef = databaseRef.child(veterinaryKey)
        deleteRef.removeValue { error, _  in
            if let error = error {
                print("=============== error \(error)")
            }
        }
    }
}
