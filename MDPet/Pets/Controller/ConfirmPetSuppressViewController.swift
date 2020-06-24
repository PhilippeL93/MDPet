//
//  ConfirmPetSuppressViewController.swift
//  MDPet
//
//  Created by Philippe on 15/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit
import Firebase

class ConfirmPetSuppressViewController: UIViewController {

    // MARK: - buttons
    @IBAction func suppressPet(_ sender: UIButton) {
        hasBeenDeleted = true
        gestSuppressPet()
        prepareToGoBack()
    }

    @IBAction func cancelSuppressPet(_ sender: Any) {
        hasBeenDeleted = false
        prepareToGoBack()
    }

    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showAnimate()
    }

    // MARK: - var
    var petItem: PetItem?
    var databaseRef = Database.database().reference(withPath: "pets-item")
    var imageRef = Storage.storage().reference().child("pets-images")
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
            self.view.alpha = 0.0
        }, completion: {(finished: Bool) in
            if (finished) {
                self.view.removeFromSuperview()
            }
        }
        )
    }
    private func prepareToGoBack() {
        NotificationCenter.default.post(name: .hasBeenDeleted, object: hasBeenDeleted)
        NotificationCenter.default.post(name: .navigationBarPetToTrue, object: self)
        self.removeAnimate()
        self.view.removeFromSuperview()
    }
    private func gestSuppressPet() {
        let path = UserUid.uid + "-pets-item"
        databaseRef = Database.database().reference(withPath: "\(path)")
        let deleteRef = databaseRef.child(petItem!.key)
        if !(petItem?.petURLPicture.isEmpty)! {
            let petKey = petItem?.key
            let imageDeleteRef = imageRef.child("\(petKey ?? "").png")
            imageDeleteRef.delete { error in
                if let error = error {
                    print("error \(error)")
                }
            }
        }
        deleteRef.removeValue { error, _  in
            if let error = error {
                print("error \(error)")
            }
        }
    }
}
