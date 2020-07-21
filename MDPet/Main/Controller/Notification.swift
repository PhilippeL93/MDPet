//
//  NotificationVeterinary.swift.swift
//  MDPet
//
//  Created by Philippe on 16/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let navigationBarPetToTrue = Notification.Name("navigationBarPetToTrue")
    static let navigationBarVeterinaryToTrue = Notification.Name("navigationBarVeterinaryToTrue")
    static let navigationBarVaccineToTrue = Notification.Name("navigationBarVaccineToTrue")
    static let navigationBarConsultationToTrue = Notification.Name("navigationBarConsultationToTrue")
    static let petIsToUpdate = Notification.Name("petIsToUpdate")
    static let veterinaryIsToUpdate = Notification.Name("veterinaryIsToUpdate")
    static let vaccineIsToUpdate = Notification.Name("vaccineIsToUpdate")
    static let consultationIsToUpdate = Notification.Name("consultationIsToUpdate")
    static let petHasBeenDeleted = Notification.Name("petHasBeenDeleted")
    static let veterinayHasBeenDeleted = Notification.Name("veterinayHasBeenDeleted")
    static let vaccineHasBeenDeleted = Notification.Name("vaccineHasBeenDeleted")
    static let consultationHasBeenDeleted = Notification.Name("consultationHasBeenDeleted")
}
