//
//  PetsItem+CoreDataProperties.swift
//  MDPet
//
//  Created by Philippe on 23/09/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//
//

//import Foundation
//import CoreData
//
//
//extension PetsItem {
//
//    @nonobjc public class func fetchRequest() -> NSFetchRequest<PetsItem> {
//        return NSFetchRequest<PetsItem>(entityName: "PetsItem")
//    }
//
//    @NSManaged public var petBirthDate: Date?
//    @NSManaged public var petBreeder: String?
//    @NSManaged public var petColor: String?
//    @NSManaged public var petDeathDate: Date?
//    @NSManaged public var petFatherName: String?
//    @NSManaged public var petGender: Int16
//    @NSManaged public var petMotherName: String?
//    @NSManaged public var petName: String?
//    @NSManaged public var petParticularSigns: String?
//    @NSManaged public var petPedigree: Bool
//    @NSManaged public var petPedigreeNumber: String?
//    @NSManaged public var petPicture: Data?
//    @NSManaged public var petRace: String?
//    @NSManaged public var petSterilized: Bool
//    @NSManaged public var petSterilizedDate: Date?
//    @NSManaged public var petTatoo: String?
//    @NSManaged public var petType: Int16
//    @NSManaged public var petURLBreeder: String?
//    @NSManaged public var petVeterinary: String?
//    @NSManaged public var petWeaning: Bool
//    @NSManaged public var petWeaningDate: Date?
//    @NSManaged public var vaccines: NSSet?
//
//}
//
//// MARK: Generated accessors for vaccines
//extension PetsItem {
//
//    @objc(addVaccinesObject:)
//    @NSManaged public func addToVaccines(_ value: VaccinesItem)
//
//    @objc(removeVaccinesObject:)
//    @NSManaged public func removeFromVaccines(_ value: VaccinesItem)
//
//    @objc(addVaccines:)
//    @NSManaged public func addToVaccines(_ values: NSSet)
//
//    @objc(removeVaccines:)
//    @NSManaged public func removeFromVaccines(_ values: NSSet)
//
//}
//
//extension PetsItem : Identifiable {
//
//}
