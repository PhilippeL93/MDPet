//
//  ActivtyView.swift
//  MDPet
//
//  Created by Philippe on 28/08/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit

var viewActivity: UIView?

extension UIViewController {
    func showActivityIndicator(onView: UIView) {
        let activityView = UIView.init(frame: onView.bounds)
        activityView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let activityIndicator = UIActivityIndicatorView.init(style: .large)
        activityIndicator.startAnimating()
        activityIndicator.center = activityView.center

        DispatchQueue.main.async {
            activityView.addSubview(activityIndicator)
            onView.addSubview(activityView)
        }
        viewActivity = activityView
    }

    func removeActivityIndicator() {
        DispatchQueue.main.async {
            viewActivity?.removeFromSuperview()
            viewActivity = nil
        }
    }
}
