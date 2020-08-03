//
//  AuthenticationGatewayFirebase.swift
//  MDPet
//
//  Created by Philippe on 29/07/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

struct AuthenticationGatewayFirebase: AuthenticationGateway {

    private let auth: Auth

    init(auth: Auth) {
        self.auth = auth
    }
    func register(userParams: RegisterUserBasicParams, completion: @escaping((RegisterResult) -> Void)) {
        auth.createUser(withEmail: userParams.email, password: userParams.password) { user, error in
            if let authError = error {
                let result = RegisterResult.failure(AuthenticationError(rawValue: authError._code))
                completion(result)
                return
            }
            if user != nil {
                let userEntity = self.generateUserEntity(identifier: userParams.email, userParams: userParams)
                let result = RegisterResult.success(userEntity)
                completion(result)
            }
        }
    }
    func connect(userParams: RegisterUserBasicParams, completion: @escaping((RegisterResult) -> Void)) {
        auth.signIn(withEmail: userParams.email, password: userParams.password) { user, error in
            if let authError = error {
                let result = RegisterResult.failure(AuthenticationError(rawValue: authError._code))
                completion(result)
                return
            }
            if user != nil {
                let userEntity = self.generateUserEntity(identifier: userParams.email, userParams: userParams)
                let result = RegisterResult.success(userEntity)
                completion(result)
            }
        }
    }
    func resetPassword(userParams: RegisterUserBasicParams, completion: @escaping((RegisterResult) -> Void)) {
        auth.sendPasswordReset(withEmail: userParams.email) { error in
            if let authError = error {
                let result = RegisterResult.failure(AuthenticationError(rawValue: authError._code))
                completion(result)
                return
            }
            let userEntity = self.generateUserEntity(identifier: userParams.email, userParams: userParams)
            let result = RegisterResult.success(userEntity)
            completion(result)
        }
    }
//    func alreadyConnected(userParams: RegisterUserBasicParams, completion: @escaping((RegisterResult) -> Void)) {
//        auth.addStateDidChangeListener { _, user  in
//            var userUid = ""
//            if user != nil {
//                userUid = user!.uid
//            }
//            let userEntity = self.generateUserEntity(identifier: userUid, userParams: userParams)
//            let result = RegisterResult.success(userEntity)
//            completion(result)
//        }
//    }
    private func generateUserEntity(identifier: String, userParams: RegisterUserBasicParams) -> User {
        return UserEntity(uid: identifier, email: userParams.email)
    }
}
