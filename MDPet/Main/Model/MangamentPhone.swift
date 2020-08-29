//
//  MangamentPhone.swift
//  MDPet
//
//  Created by Philippe on 29/08/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit

protocol PhoneStatus {}
extension NSObject: PhoneStatus {
    enum ReachabilityPhoneStatus {
        case phoneUsable
        case phoneNotUsable
    }
    var currentPhoneStatus: ReachabilityPhoneStatus {
        let phoneNumber = 0101010101
        if let url = URL(string: "telprompt://\(phoneNumber)") {
            let application = UIApplication.shared
            guard application.canOpenURL(url) else {
                return .phoneNotUsable
            }
            return .phoneUsable
        }
        return .phoneNotUsable
    }
}
