//
//  SettingsViewController.swift
//  MDPet
//
//  Created by Philippe on 02/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {

    @IBOutlet weak var automaticVaccinationGeneratedSwitch: UISwitch!
    @IBOutlet weak var vaccinationReminderActivatedSwitch: UISwitch!
    @IBOutlet weak var automaticGenerateEventInCalendarSwitch: UISwitch!

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        automaticVaccinationGeneratedSwitch.isOn = Settings.automaticVaccinationGeneratedSwitch
        vaccinationReminderActivatedSwitch.isOn = Settings.vaccinationReminderActivatedSwitch
        automaticGenerateEventInCalendarSwitch.isOn = Settings.automaticGenerateEventInCalendarSwitch
    }

    override func viewWillDisappear(_ animated: Bool) {
        Settings.automaticVaccinationGeneratedSwitch = automaticVaccinationGeneratedSwitch.isOn
        Settings.vaccinationReminderActivatedSwitch = vaccinationReminderActivatedSwitch.isOn
        Settings.automaticGenerateEventInCalendarSwitch = automaticGenerateEventInCalendarSwitch.isOn
    }

    // MARK: Properties
    var currentUsers: [String] = []
    let usersRef = Database.database().reference(withPath: "online")

    // MARK: Actions
    @IBAction func signoutButtonPressed(_ sender: AnyObject) {

        let user = Auth.auth().currentUser!
        let onlineRef = Database.database().reference(withPath: "online/\(user.uid)")
        onlineRef.removeValue { (error, _) in
            if let error = error {
                print("Removing online failed: \(error)")
                return
            }
            do {
                try Auth.auth().signOut()
                self.dismiss(animated: true, completion: nil)
            } catch (let error) {
                print("Auth sign out failed: \(error)")
            }
        }
    }

    @IBAction func touchAutomaticVaccinationGeneratedSwitch(_ sender: UISwitch) {
        Settings.automaticVaccinationGeneratedSwitch = automaticVaccinationGeneratedSwitch.isOn
    }

    @IBAction func touchVaccinationReminderActivatedSwitch(_ sender: UISwitch) {
        Settings.vaccinationReminderActivatedSwitch = vaccinationReminderActivatedSwitch.isOn
    }
    @IBAction func touchAutomaticGenerateEventInCalendar(_ sender: UISwitch) {
        Settings.automaticGenerateEventInCalendarSwitch = vaccinationReminderActivatedSwitch.isOn
    }
}
