//
//  VeterinaryItem.swift
//  MDPet
//
//  Created by Philippe on 02/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import Foundation
import Firebase

struct VeterinaryItem {

    let ref: DatabaseReference?
    let key: String
    let clinicName: String
    let veterinaryName: String
    let veterinaryFirstName: String
    let veterinaryStreetOne: String
    let veterinaryStreetTwo: String
    let veterinaryPostalCode: String
    let veterinaryCity: String
    let veterinaryPhone: String
    let veterinaryEmail: String

    init(clinic: String, key: String = "",
         name: String, firstName: String,
         streetOne: String, streetTwo: String,
         postalCode: String, city: String,
         phone: String, email: String) {
        self.ref = nil
        self.key = key
        self.clinicName = clinic
        self.veterinaryName = name
        self.veterinaryFirstName = firstName
        self.veterinaryStreetOne = streetOne
        self.veterinaryStreetTwo = streetTwo
        self.veterinaryPostalCode = postalCode
        self.veterinaryCity = city
        self.veterinaryPhone = phone
        self.veterinaryEmail = email
    }

    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let clinicName = value["clinicName"] as? String,
            let veterinaryName = value["veterinaryName"] as? String,
            let veterinaryFirstName = value["veterinarveterinaryItemyFirstName"] as? String,
            let veterinaryStreetOne = value["veterinaryStreetOne"] as? String,
            let veterinaryStreetTwo = value["veterinaryStreetTwo"] as? String,
            let veterinaryPostalCode = value["veterinaryPostalCode"] as? String,
            let veterinaryCity = value["veterinaryCity"] as? String,
            let veterinaryPhone = value["veterinaryPhone"] as? String,
            let veterinaryEmail = value["veterinaryEmail"] as? String
        else {
            return nil
        }

    self.ref = snapshot.ref
                self.key = snapshot.key
    self.clinicName = clinicName
    self.veterinaryName = veterinaryName
    self.veterinaryFirstName = veterinaryFirstName
    self.veterinaryStreetOne = veterinaryStreetOne
    self.veterinaryStreetTwo = veterinaryStreetTwo
    self.veterinaryPostalCode = veterinaryPostalCode
    self.veterinaryCity = veterinaryCity
    self.veterinaryPhone = veterinaryPhone
    self.veterinaryEmail = veterinaryEmail
  }

  func toAnyObject() -> Any {
    return [
        "clinicName": clinicName,
        "veterinaryName": veterinaryName,
        "veterinaryFirstName": veterinaryFirstName,
        "veterinaryStreetOne": veterinaryStreetOne,
        "veterinaryStreetTwo": veterinaryStreetTwo,
        "veterinaryPostalCode": veterinaryPostalCode,
        "veterinaryCity": veterinaryCity,
        "veterinaryPhone": veterinaryPhone,
        "veterinaryEmail": veterinaryEmail
    ]
  }
}
