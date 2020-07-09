//
//  SelfSizedTableView.swift
//  MDPet
//
//  Created by Philippe on 07/07/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit

class SelfSizedTableView: UITableView {

    var maxHeight: CGFloat = UIScreen.main.bounds.size.height

    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: CGSize {
        let height = min(contentSize.height, maxHeight)
        return CGSize(width: contentSize.width, height: height)
    }
}
