//
//  ConfirmConsultationSuppressViewController.swift
//  MDPet
//
//  Created by Philippe on 04/08/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit
import CoreData

class ConfirmConsultationSuppresViewController: UIViewController {

    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showAnimate()
    }

    @IBAction func suppressConsultation(_ sender: Any) {
        gestSuppressConsultation()
        consultationHasBeenDeleted = true
        prepareToGoBack()
    }

    @IBAction func cancelSuppressConsultation(_ sender: Any) {
        consultationHasBeenDeleted = false
        prepareToGoBack()
    }

    // MARK: - var
//    var petItem: PetsItem?
    var consultationObjectId: NSManagedObjectID?
    var consultationItem: ConsultationsItem?
    var consultationHasBeenDeleted = true
    var eventsCalendarManager = EventsCalendarManager()

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
        NotificationCenter.default.post(name: .consultationHasBeenDeleted, object: consultationHasBeenDeleted)
        NotificationCenter.default.post(name: .navigationBarConsultationToTrue, object: self)
        self.removeAnimate()
        self.view.removeFromSuperview()
    }
    private func gestSuppressConsultation() {
        let eventIdentifier = consultationItem?.consultationIdEvent
        if !eventIdentifier!.isEmpty {
            eventsCalendarManager.requestSuppressEvent(eventIdentifier: eventIdentifier!) { (result, _) in
                switch result {
                case .success:
                    self.getSuppressConsultationIcloud()
                case .failure(let error):
                    switch error {
                    case .calendarAccessDeniedOrRestricted:
                        self.getErrors(type: .calendarAccessDeniedOrRestricted)
                    case .eventNotAddedToCalendar:
                        self.getErrors(type: .eventNotAddedToCalendar)
                    case .eventAlreadyExistsInCalendar:
                        self.getErrors(type: .eventAlreadyExistsInCalendar)
                    case .eventDoesntExistInCalendar:
                        self.getErrors(type: .eventDoesntExistInCalendar)
                    case .eventNotUpdatedToCalendar:
                        self.getErrors(type: .eventNotUpdatedToCalendar)
                    case .eventNotSuppressedToCalendar:
                        self.getErrors(type: .eventNotSuppressedToCalendar)
                    }
                }
            }
        } else {
            getSuppressConsultationIcloud()
        }
    }
    private func getSuppressConsultationIcloud() {
        let consultationToDelete = Model.shared.getObjectByIdConsultation(objectId: consultationObjectId!)
        AppDelegate.viewContext.delete(consultationToDelete!)
        try? AppDelegate.viewContext.save()
    }
}
