//
//  AuthenticationGateway.swift
//  MDPet
//
//  Created by Philippe on 29/07/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import Foundation

typealias RegisterResult = Result<User, AuthenticationError>

protocol AuthenticationGateway {

    func register(userParams: RegisterUserBasicParams, completion: @escaping((RegisterResult) -> Void))

    func connect(userParams: RegisterUserBasicParams, completion: @escaping((RegisterResult) -> Void))

    func resetPassword(userParams: RegisterUserBasicParams, completion: @escaping((RegisterResult) -> Void))
}
