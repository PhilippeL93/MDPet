//
//  CalendarVaccine.swift
//  MDPet
//
//  Created by Philippe on 10/07/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import Foundation

struct CalendarVaccines {
    var sequency = 0
    var injection = ""
    var frequencyMonth = 0.0
    var repeate = true
    var diseases = [""]

    static let catCalendar = [
        CalendarVaccines(sequency: 0,
                         injection: "1ère injection",
                         frequencyMonth: 2,
                         repeate: false,
                         diseases: ["Coryza", "Leucose", "Typhus"]),
        CalendarVaccines(sequency: 1,
                         injection: "2ème injection",
                         frequencyMonth: 3,
                         repeate: false,
                         diseases: ["Coryza", "Leucose", "Rage", "Typhus"]),
        CalendarVaccines(sequency: 2,
                         injection: "3ème injection",
                         frequencyMonth: 4,
                         repeate: false,
                         diseases: ["Coryza", "Leucose", "Typhus"]),
        CalendarVaccines(sequency: 3,
                         injection: "Rappel",
                         frequencyMonth: 12,
                         repeate: false,
                         diseases: ["Coryza", "Leucose", "Rage", "Typhus"]),
        CalendarVaccines(sequency: 4,
                         injection: "Rappel",
                         frequencyMonth: 12,
                         repeate: true,
                         diseases: ["Coryza", "Rage"]),
        CalendarVaccines(sequency: 5,
                         injection: "Rappel",
                         frequencyMonth: 36,
                         repeate: true,
                         diseases: ["Leucose", "Typhus"])
    ]

    static let dogCalendar = [
        CalendarVaccines(sequency: 0,
                         injection: "1ère injection",
                         frequencyMonth: 1,
                         repeate: false,
                         diseases: ["Parvovirose"]),
        CalendarVaccines(sequency: 1,
                         injection: "2ème injection",
                         frequencyMonth: 2,
                         repeate: false,
                         diseases: ["Hépatite Infectieuse (Rubarth)", "Maladie de Carré",
                                    "Parvovirose", "Toux de chenil"]),
        CalendarVaccines(sequency: 2, injection: "3ème injection",
                         frequencyMonth: 3,
                         repeate: false,
                         diseases: ["Hépatite Infectieuse (Rubarth)", "Leptospirose",
                                    "Maladie de Carré", "Parvovirose", "Toux de chenil", "Rage"]),
        CalendarVaccines(sequency: 3,
                         injection: "4ème injection",
                         frequencyMonth: 4,
                         repeate: false,
                         diseases: ["Leishmaniose"]),
        CalendarVaccines(sequency: 4,
                         injection: "5ème injection",
                         frequencyMonth: 5,
                         repeate: false,
                         diseases: ["Piroplasmose"]),
        CalendarVaccines(sequency: 5,
                         injection: "Rappel",
                         frequencyMonth: 12,
                         repeate: false,
                         diseases: ["Hépatite Infectieuse (Rubarth)", "Leptospirose",
                                    "Maladie de Carré", "Parvovirose", "Toux de chenil", "Rage"]),
        CalendarVaccines(sequency: 6,
                         injection: "Rappel",
                         frequencyMonth: 12,
                         repeate: true,
                         diseases: ["Hépatite Infectieuse (Rubarth)", "Leptospirose",
                                    "Leishmaniose", "Maladie de Carré", "Parvovirose", "Toux de chenil", "Rage"])
    ]

    static let rabbitCalendar = [
        CalendarVaccines(sequency: 0,
                         injection: "3ème injection",
                         frequencyMonth: 1.5,
                         repeate: false,
                         diseases: ["Maladie virale hémorragique", "Myxomatose"]),
        CalendarVaccines(sequency: 1,
                         injection: "Rappel",
                         frequencyMonth: 12,
                         repeate: false,
                         diseases: ["Maladie virale hémorragique", "Myxomatose"]),
        CalendarVaccines(sequency: 2,
                         injection: "Rappel",
                         frequencyMonth: 12,
                         repeate: true,
                         diseases: ["Maladie virale hémorragique", "Myxomatose"])
    ]
}
