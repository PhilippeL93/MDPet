//
//  UIViewController+Alert.swift
//  MDPet
//
//  Created by Philippe on 18/02/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit

extension UIViewController {

    // MARK: - extension
    ///   alert in order to display message
    func alert(message: String, title: String ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }

    ///    getErrors in order to display message
    func getErrors(type: Errors ) {
        switch type {
        case .noCamera:
            alert(message: Errors.noCamera.rawValue, title: "Pas d'appareil photo")
        case .saveFailed:
            alert(message: Errors.saveFailed.rawValue, title: "Sauvegarde interrompue")
        case .duplicateVeterinary:
            alert(message: Errors.duplicateVeterinary.rawValue, title: "Veterinaire déjà existant")
        }
    }

    ///    getErrorsText in order to know text for error
    func getErrorsText(type: Errors ) -> String {
        switch type {
        case .noCamera:
            return Errors.noCamera.rawValue
        case .saveFailed:
            return Errors.saveFailed.rawValue
        case .duplicateVeterinary:
            return Errors.duplicateVeterinary.rawValue
        }
    }
}
