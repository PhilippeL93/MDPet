//
//  AuthenticationGatewayFirebaseTests.swift
//  MDPetTests
//
//  Created by Philippe on 31/07/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import XCTest
//import Firebase
import FirebaseAuth
import FirebaseCore

@testable import MDPet

class AuthenticationGatewayFirebaseTests: XCTestCase {

    private let userEmail = "fake@orange.fr"
    private let userPassword = "somepassword"
    private var gateway: AuthenticationGateway!
    private var auth: Auth = {
        print("================== test private var auth")
        print("================= test \(FirebaseApp.app()) ")
        if FirebaseApp.app() == nil {
            print("================= test FirebaseApp.app() == nil")
            FirebaseApp.configure()
        }
        return Auth.auth()
    }()

    override func setUp() {
        super.setUp()
        print("================== setUp")
//        FirebaseApp.configure()
        gateway = AuthenticationGatewayFirebase(auth: auth)
    }

    override func tearDown() {
        super.tearDown()
        print("================== tearDown")
//        deleteCurrentUser()
    }

//    private func deleteCurrentUser() {
//        guard let firAuthCurrentUser = auth.currentUser else { return }
//        let reference = Database.database().reference(fromURL: Enviroment.firebaseDatabase.rawValue)
//        let userReference = reference.child(DatabasePath.users.rawValue).child(firAuthCurrentUser.uid)
//
//        userReference.removeValue()
//        firAuthCurrentUser.delete { XCTAssertNil($0) }
//    }

    func testRegisterNewUserAtFirebaseReturnTheUserTroughtResultHandler() {
        let longRunningExpectation = expectation(description: "RegisterNewUser")
        var authenticationError: AuthenticationError?
        var createdUser: MDPet.User?

        let userParams = RegisterUserBasicParams(email: userEmail, password: userPassword)
        gateway.register(userParams: userParams) { result in
            print("============ result \(result) ")
            switch result {
            case let .success(user): createdUser = user
            case let .failure(error): authenticationError = error
            }
            longRunningExpectation.fulfill()
        }

        waitForExpectations(timeout: 20) { expectationError in
            XCTAssertNil(expectationError, expectationError!.localizedDescription)
            XCTAssertNil(authenticationError)
            XCTAssertNotNil(createdUser)
            XCTAssertEqual(self.userEmail, createdUser?.email)
        }
    }
}
