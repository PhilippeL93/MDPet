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

    enum Gender {
        case male, female
    }

    var imagePet: Data
    var petType: PetType
    var name: String
    var gender: Gender
    var birdthDate: String
    var tatoo: String
    var sterilized: Bool
    var sterilizedDate: String
    var veterinary: String
    var race: String
    var weaning: Bool
    var weaningDate: String
    var deathDate: String
}

extension Pets {
    enum Status {
        case accepted
        case rejected(String)
    }

    var status: Status {
        if name.isEmpty {
            return .rejected("Vous n'avez pas indiqué votre nom !")
        }
        if race.isEmpty {
            return .rejected("Quel est la race de votre animal?")
        }
        return .accepted
    }
}
