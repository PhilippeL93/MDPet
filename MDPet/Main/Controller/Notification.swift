//
//  NotificationVeterinary.swift.swift
//  MDPet
//
//  Created by Philippe on 16/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let navigationBarVeterinaryToTrue = Notification.Name("navigationBarVeterinaryToTrue")
    static let navigationBarPetToTrue = Notification.Name("navigationBarPetToTrue")
    static let navigationBarVaccineToTrue = Notification.Name("navigationBarVaccineToTrue")
    static let isToUpdate = Notification.Name("isToUpdate")
    static let hasBeenDeleted = Notification.Name("hasBeenDeleted")
}
