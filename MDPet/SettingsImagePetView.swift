//
//  SettingsImagePetView.swift
//  MDPet
//
//  Created by Philippe on 09/02/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit

@IBDesignable

// MARK: class SettingsImagePetView
///    in order to manage
///    - border in color
///    - rounded corner
class SettingsImagePetView: UIImageView {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
}
