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
    var petName: String
    var petURLPicture: String
    var petType: Int
    var petGender: Int
    var petBirthDate: String
    var petTatoo: String
    var petSterilized: Bool
    var petSterilizedDate: String
    var petVeterinary: String
    var petRace: String
    var petWeaning: Bool
    var petWeaningDate: String
    var petDeathDate: String

    init(name: String, key: String = "",
         URLPicture: String, type: Int,
         gender: Int, birthDate: String,
         tatoo: String, sterilized: Bool,
         sterilizedDate: String, veterinary: String,
         race: String, weaning: Bool,
         weaningDate: String, deathDate: String) {
        self.ref = nil
        self.key = key
        self.petName = name
        self.petURLPicture = URLPicture
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
            let petURLPicture = value["petURLPicture"] as? String,
            let petType = value["petType"] as? Int,
            let petGender = value["petGender"] as? Int,
            let petBirthDate = value["petBirthDate"] as? String,
            let petTatoo = value["petTatoo"] as? String,
            let petSterilized = value["petSterilized"] as? Bool,
            let petSterilizedDate = value["petSterilizedDate"] as? String,
            let petVeterinary = value["petVeterinary"] as? String,
            let petRace = value["petRace"] as? String,
            let petWeaning = value["petWeaning"] as? Bool,
            let petWeaningDate = value["petWeaningDate"] as? String ,
            let petDeathDate = value["petDeathDate"] as? String
            else {
                return nil
        }

        self.ref = snapshot.ref
        self.key = snapshot.key
        self.petName = petName
        self.petURLPicture = petURLPicture
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
            "petURLPicture": petURLPicture,
            "petType": petType,
            "petGender": petGender,
            "petBirthDate": petBirthDate,
            "petTatoo": petTatoo,
            "petSterilized": petSterilized,
            "petSterilizedDate": petSterilizedDate,
            "petVeterinary": petVeterinary,
            "petRace": petRace,
            "petWeaning": petWeaning,
            "petWeaningDate": petWeaningDate,
            "petDeathDate": petDeathDate
        ]
    }
}