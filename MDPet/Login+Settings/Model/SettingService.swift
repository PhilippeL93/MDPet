//
//  SettingService.swift
//  MDPet
//
//  Created by Philippe on 07/07/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import Foundation

class SettingService {
    private struct Keys {
        static let automaticVaccinationGeneratedSwitch = "automaticVaccinationGeneratedSwitch"
        static let vaccinationReminderActivatedSwitch = "vaccinationReminderActivatedSwitch"
    }
    static var automaticVaccinationGeneratedSwitch: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.automaticVaccinationGeneratedSwitch)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.automaticVaccinationGeneratedSwitch)
        }
    }
    static var vaccinationReminderActivatedSwitch: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.vaccinationReminderActivatedSwitch)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.vaccinationReminderActivatedSwitch)
        }
    }
}
