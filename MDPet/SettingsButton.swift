//
//  SettingsButton.swift
//  MDPet
//
//  Created by Philippe on 09/02/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import Foundation
import UIKit

// MARK: - class SettingsButton
class SettingsButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
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
