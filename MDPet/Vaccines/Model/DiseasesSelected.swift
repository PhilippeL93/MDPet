//
//  DiseasesSelected.swift
//  MDPet
//
//  Created by Philippe on 02/07/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import Foundation

class DiseasesSelected {
    var diseaseName: String
    var diseaseSwitch: Bool

    init(diseaseName: String, diseaseSwitch: Bool) {
        self.diseaseName = diseaseName
        self.diseaseSwitch = diseaseSwitch
    }
}
