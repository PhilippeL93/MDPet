//
//  PresentConsultationCell.swift
//  MDPet
//
//  Created by Philippe on 21/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit

class PresentConsultationCell: UITableViewCell {

    @IBOutlet weak var consultationReasonLabel: UILabel!
    @IBOutlet weak var consultationVeterinaryLabel: UILabel!
    @IBOutlet weak var consultationDateLabel: UILabel!

    private let localeLanguage = Locale(identifier: "FR-fr")
    private var dateFormatter = DateFormatter()
    var consultationItem: ConsultationItem?

    func configureConsultationCell(consultationItem: ConsultationItem, callback: @escaping (Bool) -> Void ) {

        dateFormatter.dateFormat = dateFormatyyyyMMddHHmm
        let dateDMY = dateFormatter.date(from: consultationItem.consultationDate)
        dateFormatter.dateFormat = dateFormatddMMyyyyWithSlashes
        let dateToDisplay = dateFormatter.string(from: dateDMY!)
        consultationReasonLabel.text = consultationItem.consultationReason
        consultationDateLabel.text = String(dateToDisplay)

        GetFirebaseVeterinaries.shared.getVeterinaryFromKey(
        veterinaryToSearch: consultationItem.consultationVeterinary) { (success, veterinariesItems, _) in
            if success {
                self.consultationVeterinaryLabel.text = veterinariesItems.veterinaryName
            }
        }
    }
}
