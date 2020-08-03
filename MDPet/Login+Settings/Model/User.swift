//
//  User.swift
//  MDPet
//
//  Created by Philippe on 02/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import Foundation
import FirebaseAuth

public typealias RegisterUserBasicParams = (email: String, password: String)

protocol User {
    var uid: String { get }
    var email: String { get }
}

struct UserEntity: User {

  let uid: String
  let email: String

  init(authData: FirebaseAuth.User) {
    uid = authData.uid
    email = authData.email!
  }

  init(uid: String, email: String) {
    self.uid = uid
    self.email = email
  }
}
