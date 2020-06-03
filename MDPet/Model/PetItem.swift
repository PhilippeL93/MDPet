//
//  PetItem.swift
//  MDPet
//
//  Created by Philippe on 02/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import Foundation
import Firebase

struct PetItem {

    let ref: DatabaseReference?
    let key: String
    var petPicture: Data
    var petType: PetType
    var petName: String
    var petGender: PetGender
    var petBirthDate: Date
    var petTatoo: String
    var petSterilized: Bool
    var petSterilizedDate: Date
    var petVeterinary: String
    var petRace: String
    var petWeaning: Bool
    var petWeaningDate: Date
    var petDeathDate: Date

    enum PetType {
        case cat, dog, rabbit, rodent
    }

    enum PetGender {
        case male, female
    }
    
    init(name: String, key: String = "",
         picture: Data, type: PetType,
         gender: PetGender, birthDate: Date,
         tatoo: String, sterilized: Bool,
         sterilizedDate: Date, veterinary: String,
         race: String, weaning: Bool,
         weaningDate: Date, deathDate: Date) {
        self.ref = nil
        self.key = key
        self.petName = name
        self.petPicture = picture
        self.petType = type
        self.petGender = gender
        self.petBirthDate = birthDate
        self.petTatoo = tatoo
        self.petSterilized = sterilized
        self.petSterilizedDate = sterilizedDate
        self.petVeterinary = veterinary
        self.petRace = race
        self.petWeaning = weaning
        self.petWeaningDate = weaningDate
        self.petDeathDate = deathDate
    }

    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let petName = value["petName"] as? String,
            let petPicture = value["petPicture"] as? Data,
            let petType = value["petType"] as? PetType,
            let petGender = value["petGender"] as? PetGender,
            let petBirthDate = value["petBirthDate"] as? Date,
            let petTatoo = value["petTatoo"] as? String,
            let petSterilized = value["petSterilized"] as? Bool,
            let petSterilizedDate = value["petSterilizedDate"] as? Date,
            let petVeterinary = value["petVeterinary"] as? String,
            let petRace = value["petRace"] as? String,
            let petWeaning = value["petWeaning"] as? Bool,
            let petWeaningDate = value["petWeaningDate"] as? Date ,
            let petDeathDate = value["petDeathDate"] as? Date else {
                return nil
        }

        self.ref = snapshot.ref
        self.key = snapshot.key
        self.petName = petName
        self.petPicture = petPicture
        self.petType = petType
        self.petGender = petGender
        self.petBirthDate = petBirthDate
        self.petTatoo = petTatoo
        self.petSterilized = petSterilized
        self.petSterilizedDate = petSterilizedDate
        self.petVeterinary = petVeterinary
        self.petRace = petRace
        self.petWeaning = petWeaning
        self.petWeaningDate = petWeaningDate
        self.petDeathDate = petDeathDate
  }

    func toAnyObject() -> Any {
        return [
            "petName": petName,
            "petPicture"  : petPicture,
            "petType"  : petType,
            "petGender"  : petGender,
            "petBirthDate"  : petBirthDate,
            "petTatoo"  : petTatoo,
            "petSterilized"  : petSterilized,
            "petSterilizedDate"  : petSterilizedDate,
            "petVeterinary"  : petVeterinary,
            "petRace"  : petRace,
            "petWeaning"  : petWeaning,
            "petWeaningDate"  : petWeaningDate,
            "petDeathDate"  : petDeathDate
        ]
    }
}
