//
//  ManagmentUserFirebase.swift
//  MDPet
//
//  Created by Philippe on 29/07/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import Foundation

struct ManagmentUserFirebase {

    private let gateway: AuthenticationGateway

    init(gateway: AuthenticationGateway) {
        self.gateway = gateway
    }
    func register(userParams: RegisterUserBasicParams, completion: @escaping ((RegisterResult) -> Void)) {
        gateway.connect(userParams: userParams) { result in
            completion(result)
        }
    }
    func connect(userParams: RegisterUserBasicParams, completion: @escaping ((RegisterResult) -> Void)) {
        gateway.connect(userParams: userParams) { result in
            completion(result)
        }
    }
    func resetPassword(userParams: RegisterUserBasicParams, completion: @escaping ((RegisterResult) -> Void)) {
        gateway.connect(userParams: userParams) { result in
            completion(result)
        }
    }
}
