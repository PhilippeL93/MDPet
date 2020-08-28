//
//  ConnectionType.swift
//  MDPet
//
//  Created by Philippe on 27/08/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import SystemConfiguration
import CoreTelephony

protocol Utilities {}
extension NSObject: Utilities {
    enum ReachabilityStatus {
        case notReachable
        case reachableViaWWAN
        case reachableViaWiFi
        case twoG
        case threeG
        case fourG
    }

    var currentReachabilityStatus: ReachabilityStatus {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return .notReachable
        }

        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return .notReachable
        }
        if flags.contains(.reachable) == false {
            // The target host is not reachable.
            return .notReachable
        }
        if flags.contains(.isWWAN) == true {
            // WWAN connections are OK if the calling application is using the CFNetwork APIs.
            let networkInfo = CTTelephonyNetworkInfo()
            let carrierType = networkInfo.currentRadioAccessTechnology
            guard let carrierTypeName = carrierType else {
                return .notReachable
            }
            switch carrierTypeName {
            case CTRadioAccessTechnologyGPRS, CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyCDMA1x:
                return .twoG
            case CTRadioAccessTechnologyLTE:
                return .fourG
            default:
                return .threeG
            }
        }
        if flags.contains(.connectionRequired) == false {
            // If the target host is reachable and no connection is required then we'll assume that you're on Wi-Fi...
            return .reachableViaWiFi
        }
        if (flags.contains(.connectionOnDemand) == true
            || flags.contains(.connectionOnTraffic) == true)
            && flags.contains(.interventionRequired) == false {
            // The connection is on-demand (or on-traffic)
            // if the calling application is using the CFSocketStream
            // or higher APIs and no [user] intervention is needed
            return .reachableViaWiFi
        }
        return .notReachable
    }
}
