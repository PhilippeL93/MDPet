//
//  AuthenticationErrorValidator.swift
//  MDPet
//
//  Created by Philippe on 30/07/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import Foundation

protocol AuthenticationErrorValidator {
    var error: AuthenticationError { get }
    func isValid() -> Bool
}
