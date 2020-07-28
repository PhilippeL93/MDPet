//
//  Settings.swift
//  MDPet
//
//  Created by Philippe on 07/07/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import Foundation

class Settings {
    private struct Keys {
        static let automaticVaccinationGeneratedSwitch = "automaticVaccinationGeneratedSwitch"
        static let vaccinationReminderActivatedSwitch = "vaccinationReminderActivatedSwitch"
        static let automaticGenerateEventInCalendarSwitch = "automaticGenerateEventInCalendarSwitch"
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
    static var automaticGenerateEventInCalendarSwitch: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.automaticGenerateEventInCalendarSwitch)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.automaticGenerateEventInCalendarSwitch)
        }
    }
}
