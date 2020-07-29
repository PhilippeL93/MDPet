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
        case .eventAddedSuccessfully:
            alert(message: Errors.eventAddedSuccessfully.rawValue, title: "Calendrier")
        case .eventRemovedSuccessfully:
            alert(message: Errors.eventRemovedSuccessfully.rawValue, title: "Calendrier")
        case .calendarAccessDeniedOrRestricted:
            alert(message: Errors.calendarAccessDeniedOrRestricted.rawValue, title: "Calendrier")
        case .eventNotAddedToCalendar:
            alert(message: Errors.eventNotAddedToCalendar.rawValue, title: "Calendrier")
        case .eventAlreadyExistsInCalendar:
            alert(message: Errors.eventAlreadyExistsInCalendar.rawValue, title: "Calendrier")
        case .eventDoesntExistInCalendar:
            alert(message: Errors.eventDoesntExistInCalendar.rawValue, title: "Calendrier")
        case .eventNotUpdatedToCalendar:
            alert(message: Errors.eventNotUpdatedToCalendar.rawValue, title: "Calendrier")
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
        case .eventAddedSuccessfully:
            return Errors.eventAddedSuccessfully.rawValue
        case .eventRemovedSuccessfully:
            return Errors.eventRemovedSuccessfully.rawValue
        case .calendarAccessDeniedOrRestricted:
            return Errors.calendarAccessDeniedOrRestricted.rawValue
        case .eventNotAddedToCalendar:
            return Errors.eventNotAddedToCalendar.rawValue
        case .eventAlreadyExistsInCalendar:
            return Errors.eventAlreadyExistsInCalendar.rawValue
        case .eventDoesntExistInCalendar:
            return Errors.eventDoesntExistInCalendar.rawValue
        case .eventNotUpdatedToCalendar:
            return Errors.eventNotUpdatedToCalendar.rawValue
        }
    }
}
