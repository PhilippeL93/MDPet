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

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        automaticVaccinationGeneratedSwitch.isOn = SettingService.automaticVaccinationGeneratedSwitch
        vaccinationReminderActivatedSwitch.isOn = SettingService.vaccinationReminderActivatedSwitch
    }

    override func viewWillDisappear(_ animated: Bool) {
        SettingService.automaticVaccinationGeneratedSwitch = automaticVaccinationGeneratedSwitch.isOn
        SettingService.vaccinationReminderActivatedSwitch = vaccinationReminderActivatedSwitch.isOn
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
        SettingService.automaticVaccinationGeneratedSwitch = automaticVaccinationGeneratedSwitch.isOn
    }

    @IBAction func touchVaccinationReminderActivatedSwitch(_ sender: UISwitch) {
        SettingService.vaccinationReminderActivatedSwitch = vaccinationReminderActivatedSwitch.isOn
    }
}
