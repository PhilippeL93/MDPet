//
//  VaccinesItem+CoreDataProperties.swift
//  MDPet
//
//  Created by Philippe on 23/09/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//
//

import Foundation
import CoreData

extension VaccinesItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VaccinesItem> {
        return NSFetchRequest<VaccinesItem>(entityName: "VaccinesItem")
    }

    @NSManaged public var vaccineDate: Date?
    @NSManaged public var vaccineDiseases: [String]?
    @NSManaged public var vaccineDone: Bool
    @NSManaged public var vaccineInjection: String?
    @NSManaged public var vaccineName: String?
    @NSManaged public var vaccineSwitchDiseases: [Bool]?
    @NSManaged public var vaccineThumbnail: Data?
    @NSManaged public var vaccineVeterinary: String?
    @NSManaged public var pet: PetsItem?

}

extension VaccinesItem: Identifiable {

}
