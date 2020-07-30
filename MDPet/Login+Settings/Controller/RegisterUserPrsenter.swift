//
//  RegisterUserPrsenter.swift
//  MDPet
//
//  Created by Philippe on 30/07/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

protocol RegisterUserPresenter {
    func success()
    func failure(error: AuthenticationError)
}
