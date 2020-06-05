//
//  Pets.swift
//  MDPet
//
//  Created by Philippe on 18/02/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import Foundation

struct Pets {

    enum PetType {
        case cat, dog, rabbit, rodent
    }

    enum PetGender {
        case male, female
    }

    var petPicture: Data
    var petType: PetType
    var petName: String
    var petGender: PetGender
    var petBirthDate: String
    var petTatoo: String
    var petSterilized: Bool
    var petSterilizedDate: String
    var petVeterinary: String
    var petRace: String
    var petWeaning: Bool
    var petWeaningDate: String
    var petDeathDate: String
}

extension Pets {
    enum Status {
        case accepted
        case rejected(String)
    }

    var status: Status {
        if petName.isEmpty {
            return .rejected("Vous n'avez pas indiqué de nom !")
        }
        if petRace.isEmpty {
            return .rejected("Quel est la race de votre animal?")
        }
        return .accepted
    }
}
