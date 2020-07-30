//
//  MDPetTests.swift
//  MDPetTests
//
//  Created by Philippe on 29/11/2019.
//  Copyright © 2019 Philippe. All rights reserved.
//

import XCTest
import Firebase

@testable import MDPet

class AuthenticationGatewayStub: AuthenticationGateway {

    var registeredUser: UserEntity?
    var registerResult: Result<UserEntity, AuthenticationError>?

    func register(name: String, email: String, password: String, birthdate: Date,
                  completion: @escaping ((Result<UserEntity, AuthenticationError>) -> Void)) {
        guard let registerResult = registerResult else { return }

        switch registerResult {
        case .failure(_):
            registeredUser = nil
        case .success(_):
            registeredUser = UserEntity(identifier: nil, name: name, email: email, birthdate: birthdate)
        }
        completion(registerResult)
    }
}

class RegisterUserUsecaseTests: XCTestCase {

    // ...
    private var usecase: RegisterUserUsecase!
    private var presenter: RegisterUserPresenterStub!
    private var gateway: AuthenticationGatewayStub!

    override func setUp() {
        // Gateway Mock instead Gateway with firebase
        gateway = AuthenticationGatewayStub()
        presenter = RegisterUserPresenterStub()
        usecase = RegisterUserUsecase(gateway: gateway, presenter: presenter)
    }

    // ...
    func testRegisterAnUserWithValidInputSaveDataAndPresentSuccessMessage() {
        let user = generateUserEntity()
        // Applying expected behavior in the gateway
        gateway.registerResult = Result.success(user)
        // ...
    }
}
