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
    private var veterinaryItem: VeterinariesItem?

    func configureConsultationCell(consultationItem: ConsultationsItem, callback: @escaping (Bool) -> Void ) {

        if consultationItem.consultationDate != nil {
            dateFormatter.locale = localeLanguage
            dateFormatter.dateFormat = dateFormatddMMyyyyWithSlashes
            let consultationDate = dateFormatter.string(from: consultationItem.consultationDate!)
            consultationDateLabel.text = consultationDate
        } else {
            consultationDateLabel.text = ""
        }
        consultationReasonLabel.text = consultationItem.consultationReason

        Model.shared.getVeterinaryFromRecordID(
            veterinaryToSearch: consultationItem.consultationVeterinary!) { (success, veterinaryItem) in
            if success {
                self.consultationVeterinaryLabel.text = veterinaryItem?.veterinaryName!
            }
        }
    }
}
