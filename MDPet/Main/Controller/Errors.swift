//
//  Errors.swift
//  MDPet
//
//  Created by Philippe on 18/02/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import Foundation

// MARK: enum Errors
enum Errors: String {
    case noCamera = "Désolé, cet appareil n'a pas d'appareil photo"
    case saveFailed = "Image non sauvegardée"
    case duplicateVeterinary = "Numéro ordinal déjà utilisé"
    case eventAddedSuccessfully = "Evènement ajouté"
    case eventRemovedSuccessfully = "Evènement supprimé"
    case calendarAccessDeniedOrRestricted = "Pas d'accès au calednrier"
    case eventNotAddedToCalendar = "Evènement non ajouté au calendrier"
    case eventAlreadyExistsInCalendar = "Evènement déjà existant"
    case eventDoesntExistInCalendar = "Evènement non trouvé"
    case eventNotUpdatedToCalendar = "Evènement non mis à jour"
//    case invalidName = "Nom inconnu"
//    case invalidPassword = "Mot de passe incorrect"
//    case userDisabled = "Utilisateur désactivé"
//    case emailAlreadyInUse = "Utilisateur déjà existant"
//    case invalidEmail = "Email invalide"
//    case wrongPassword = "Mot de passe non robuste"
//    case userNotFound = "Utilisateur inconnu"
//    case accountExistsWithDifferentCredential = "Compte déjà existant"
//    case networkError = "Pas de connexion"
//    case credentialAlreadyInUse = "Compte déjà utilisé"
//    case unknown = "Erreur inconnu"
}
