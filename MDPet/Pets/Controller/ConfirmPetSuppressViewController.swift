//
//  ConfirmPetSuppressViewController.swift
//  MDPet
//
//  Created by Philippe on 15/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class ConfirmPetSuppressViewController: UIViewController {

    // MARK: - buttons
    @IBAction func suppressPet(_ sender: UIButton) {
        petHasBeenDeleted = true
        gestSuppressPet()
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
    var petItem: PetItem?
    var databaseRef = Database.database().reference(withPath: petsItem)
    var imageRef = Storage.storage().reference().child(petsInages)
    var petHasBeenDeleted = true

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
        let path = UserUid.uid + petsItem
        let petKey = petItem?.key
        databaseRef = Database.database().reference(withPath: "\(path)")
        let deleteRefPet = databaseRef.child(petItem!.key)
        if !(petItem?.petURLPicture.isEmpty)! {
            let imageDeleteRef = imageRef.child("\(petKey ?? "").png")
            imageDeleteRef.delete { error in
                if let error = error {
                    print("error \(error)")
                }
            }
        }
        GetFirebaseVaccines.shared.deleteVaccines(petKey: petKey!) { (success) in
            if !success {
                print("erreur")
            }
        }
        GetFirebaseConsultations.shared.deleteConsultations(petKey: petKey!) { (success) in
            if success {
                deleteRefPet.removeValue { error, _  in
                    if let error = error {
                        print("error \(error)")
                    }
                }
            } else {
                print("erreur")
            }
        }
    }
}
