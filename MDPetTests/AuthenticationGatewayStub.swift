//
//  AuthenticationGatewayStub.swift
//  MDPetTests
//
//  Created by Philippe on 29/11/2019.
//  Copyright © 2019 Philippe. All rights reserved.
//

import XCTest
import Firebase

@testable import MDPet

class AuthenticationGatewayStub: AuthenticationGateway {
    
    var registeredUser: MDPet.User?
    var registerResult: Result<MDPet.User, AuthenticationError>?

    func register(userParams: RegisterUserBasicParams, completion: @escaping ((RegisterResult) -> Void)) {
        guard let registerResult = registerResult else { return }

        switch registerResult {
        case .failure(_):
            registeredUser = nil
        case .success(_):
            registeredUser = UserEntity(uid: userParams.email, email: userParams.email)
        }
        completion(registerResult)
    }
    
    func connect(userParams: RegisterUserBasicParams, completion: @escaping ((RegisterResult) -> Void)) {
        guard let registerResult = registerResult else { return }

        switch registerResult {
        case .failure(_):
            registeredUser = nil
        case .success(_):
            registeredUser = UserEntity(uid: userParams.email, email: userParams.email)
        }
        completion(registerResult)
    }
    
    func resetPassword(userParams: RegisterUserBasicParams, completion: @escaping ((RegisterResult) -> Void)) {
        guard let registerResult = registerResult else { return }

        switch registerResult {
        case .failure(_):
            registeredUser = nil
        case .success(_):
            registeredUser = UserEntity(uid: userParams.email, email: userParams.email)
        }
        completion(registerResult)
    }
    
}

//class ManagmentUserFirebaseTests: XCTestCase {
//
//    // ...
//    private var usecase: ManagmentUserFirebase!
//    private var presenter: ManagmentUserFirebaseStub!
//    private var gateway: AuthenticationGatewayStub!
//
//    override func setUp() {
//        // Gateway Mock instead Gateway with firebase
//        gateway = AuthenticationGatewayStub()
////        presenter = RegisterUserPresenterStub()
//        usecase = User(gateway: gateway, presenter: presenter)
//    }
//
//    // ...
//    func testRegisterAnUserWithValidInputSaveDataAndPresentSuccessMessage() {
//        let user = generateUserEntity()
//        // Applying expected behavior in the gateway
//        gateway.registerResult = Result.success(user)
//        // ...
//    }
//}
