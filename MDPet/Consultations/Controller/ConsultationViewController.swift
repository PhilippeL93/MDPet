//
//  ConsultationViewController.swift
//  MDPet
//
//  Created by Philippe on 10/07/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit
import Firebase
import EventKit

class ConsultationViewController: UIViewController {

    @IBOutlet weak var consultationPetNameLabel: UILabel!
    @IBOutlet weak var consultationReasonField: UITextField!
    @IBOutlet weak var consultationDateField: UITextField!
    @IBOutlet weak var consultationVeterinaryField: UITextField!
    @IBOutlet weak var consultationWeightField: UITextField!
    @IBOutlet weak var consultationReportView: UITextView!
    @IBOutlet weak var saveConsultationButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - variables
    private var consultationReason: UITextField?
    private var datePickerConsultationDate: UIDatePicker?
    private var pickerViewVeterinary = UIPickerView()
    private var consultationWeight: UITextField?
    private var activeField: UITextField?
    private var lastOffset: CGPoint!
    private var keyboardHeight: CGFloat!
    private var constraintContentHeight: CGFloat!
    private let localeLanguage = Locale(identifier: "FR-fr")
    private var dateFormatter = DateFormatter()
    private var selectedVeterinaryKey: String = ""
    private var typeFieldOrView: String = ""
    private var selectedVeterinaryName = ""
    private var consultationIdEvent = ""

    var veterinariesItems: [VeterinaryItem] = []
    var consultationsItems: [ConsultationItem] = []
    //    var typeOfCall: String = ""
    var typeOfCall: TypeOfCall?
    var petItem: PetItem?
    var consultationItem: ConsultationItem?
    var eventsCalendarManager = EventsCalendarManager()
    private var consultationKey: String = ""
    private var databaseRef = Database.database().reference(withPath: consultationsItem)
    private var pathConsultation: String = ""
    private var consultationDateToSave: String = ""

    private var fieldsUpdated: [String: Bool] = [:] {
        didSet {
            var oneFieldHasBeenUpdated = false
            for (_, hasBeenUpdated) in fieldsUpdated
                where hasBeenUpdated == true {
                    oneFieldHasBeenUpdated = true
            }
             if case .create = typeOfCall {
                toggleSaveConsultationButton(shown: false)
                checkConsultationComplete()
            } else {
                toggleSaveConsultationButton(shown: oneFieldHasBeenUpdated)
            }
        }
    }
    @IBAction func saveConsultation(_ sender: Any) {
        createOrUpdateConsultation()
    }
    @IBAction func backToConsultations(_ sender: UIBarButtonItem) {
        activeField?.resignFirstResponder()
        activeField = nil
        checkUpdateConsultationDone()
    }
    @IBAction func veterinaryEditingDidBegin(_ sender: Any) {
        if !consultationVeterinaryField.text!.isEmpty {
            GetFirebaseVeterinaries.shared.getVeterinaryFromKey(
            veterinaryToSearch: selectedVeterinaryKey) { (success, _, rowVeterinary) in
                if success {
                    self.pickerViewVeterinary.selectRow(rowVeterinary, inComponent: 0, animated: true)
                }
            }
        } else {
            pickerViewVeterinary.selectRow(0, inComponent: 0, animated: true)
        }
    }
    @IBAction func consultationDateEditingDidBegin(_ sender: Any) {
        formatDate()
        if consultationDateField.text!.isEmpty {
            let date = Date()
            consultationDateField.text = dateFormatter.string(from: date)
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            consultationDateToSave = dateFormatter.string(from: date)
        } else {
            formatDate()
            let consultationDate = dateFormatter.date(from: consultationDateField.text!)
            datePickerConsultationDate?.date = consultationDate!
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            consultationDateToSave = dateFormatter.string(from: consultationDate!)
        }
    }

// MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.locale = localeLanguage
        formatDate()
        pathConsultation = UserUid.uid + consultationsItem + petItem!.key
        databaseRef = Database.database().reference(withPath: "\(pathConsultation)")
        createObserverConsultation()
        createDelegateConsultation()
        initiateObserverConsultation()
        GetFirebaseVeterinaries.shared.observeVeterinaries { (success, veterinariesItems) in
            if success {
                self.veterinariesItems = veterinariesItems
                if case .update = self.typeOfCall {
                    self.initiateConsultationView()
                }
                self.initiateButtonConsultationView()
            } else {
                print("erreur")
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .navigationBarConsultationToTrue, object: nil)
        NotificationCenter.default.removeObserver(self, name: .consultationIsToUpdate, object: nil)
        NotificationCenter.default.removeObserver(self, name: .consultationHasBeenDeleted, object: nil)
    }
    // MARK: - @objc func
    @objc func tapGestuireRecognizer(gesture: UIGestureRecognizer) {
            guard !typeFieldOrView.isEmpty else {
                return
            }
            if typeFieldOrView == "UITextField" {
                guard activeField != nil else {
                    return
                }
                if #available(iOS 13.0, *) {
                    activeField?.textColor = UIColor.label
                } else {
                    activeField?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                }
                activeField?.resignFirstResponder()
                activeField = nil
            } else {
                if #available(iOS 13.0, *) {
                    consultationReportView.textColor = UIColor.label
                } else {
                    consultationReportView.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                }
                consultationReportView.resignFirstResponder()
            }
            typeFieldOrView = ""
        }
    @objc func navigationBarConsultationToTrue(notification: Notification) {
        navigationController?.navigationBar.isUserInteractionEnabled = true
    }
    @objc func isConsultationToUpdate(notification: Notification) {
        navigationController?.navigationBar.isUserInteractionEnabled = true
        var isToUpdate = true
        if let object = notification.object as? Bool {
            isToUpdate = object
        }
        if isToUpdate == false {
            navigationController?.popViewController(animated: true)
            return
        }
    }
    @objc func consultationReasonFieldDidEnd(_ textField: UITextField) {
        if consultationReasonField.text != consultationItem?.consultationReason {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "consultationReasonUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "consultationReasonUpdated")
        }
    }
    @objc func dateChangedConsultationDate(datePicker: UIDatePicker) {
        consultationDateField.text = dateFormatter.string(from: datePicker.date)
        if consultationDateField.text != consultationItem?.consultationDate {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "consultationDateUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "consultationDateUpdated")
        }
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        consultationDateToSave = dateFormatter.string(from: datePicker.date)
        formatDate()
        consultationDateField.text = dateFormatter.string(from: datePicker.date)
    }
    @objc func consultationVeterinaryFieldDidEnd(_ textField: UITextField) {
        selectedVeterinaryName = ""
        if case .update = typeOfCall {
            GetFirebaseVeterinaries.shared.getVeterinaryFromKey(
            veterinaryToSearch: consultationItem!.consultationVeterinary) { (success, veterinaryName, _) in
                if success {
                    self.selectedVeterinaryName = veterinaryName
                }
            }
        }
        if consultationVeterinaryField.text != selectedVeterinaryName {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "consultationVeterinaryUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "consultationVeterinaryUpdated")
        }
    }
    @objc func consultationWeightFieldDidEnd(_ textField: UITextField) {
        if consultationWeightField.text! != consultationItem?.consultationWeight {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "consultationWeightUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "consultationWeightUpdated")
        }
    }
    private func updateDictionnaryFieldsUpdated(updated: Bool, forKey: String) {
        fieldsUpdated.updateValue(updated, forKey: forKey)
    }
    // MARK: - functions
    private func createObserverConsultation() {
        createObserverConsultationReason()
        createObserverConsultationDatePickerView()
        createObserverConsultationVeterinaryPickerView()
        createObserverConsultationWeight()
    }
    private func createDelegateConsultation() {
        consultationReasonField.delegate = self
        consultationDateField.delegate = self
        consultationVeterinaryField.delegate = self
        consultationWeightField.delegate = self
        consultationReportView.delegate = self
    }
    private func initiateObserverConsultation() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(navigationBarConsultationToTrue),
                                               name: .navigationBarConsultationToTrue, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(isConsultationToUpdate),
                                               name: .consultationIsToUpdate, object: nil)
//        ici
//        NotificationCenter.default.addObserver(self, selector: #selector(isConsultationDeleted),
//                                               name: .consultationHasBeenDeleted, object: nil)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                              action: #selector(tapGestuireRecognizer(gesture:))))
    }
    private func initiateButtonConsultationView() {
        toggleActivityIndicator(shown: false)
        toggleSaveConsultationButton(shown: false)
        consultationPetNameLabel.text = petItem?.petName
        if case .create = typeOfCall {
            saveConsultationButton.title = "Ajouter"
            self.title = "Nouvelle consultation"
            //        ici
            //            suppressConsultationButton.isHidden = true
        } else {
            saveConsultationButton.title = "OK"
            self.title = "Modification consultation"
        }
        if consultationReportView.text.isEmpty {
            consultationReportView.text = "Compte-rendu"
            consultationReportView.textColor = UIColor.lightGray
            consultationReportView.font = UIFont(name: "raleway", size: 17.0)
            consultationReportView.returnKeyType = .done
            consultationReportView.delegate = self
        }
    }
    private func initiateConsultationView() {
        consultationKey = consultationItem?.key ?? ""
        consultationReasonField.text = consultationItem?.consultationReason
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let consultationDate = dateFormatter.date(from: consultationItem!.consultationDate)
        consultationDateToSave = dateFormatter.string(from: consultationDate!)
        dateFormatter.dateFormat = "dd MMMM yyyy HH:mm"
        consultationDateField.text = dateFormatter.string(from: consultationDate!)
        consultationWeightField.text = consultationItem?.consultationWeight
        consultationReportView.text = consultationItem?.consultationReport

        GetFirebaseVeterinaries.shared.getVeterinaryFromKey(
        veterinaryToSearch: consultationItem!.consultationVeterinary) { (success, veterinaryName, _) in
            if success {
                self.consultationVeterinaryField.text = veterinaryName
            }
        }
        selectedVeterinaryKey = consultationItem?.consultationVeterinary ?? ""
    }
    private func checkUpdateConsultationDone() {
        if saveConsultationButton.isEnabled == false {
            navigationController?.popViewController(animated: true)
            return
        }
        navigationController?.navigationBar.isUserInteractionEnabled = false
        guard let destVC = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmUpdate")
            as? ConfirmUpdateViewController else {
                return
        }
        self.addChild(destVC)
        destVC.typeOfCaller = TypeOfCaller.consultation
        destVC.view.frame = self.view.frame
        self.view.addSubview(destVC.view)
        destVC.didMove(toParent: self)
    }
    private func createOrUpdateConsultation() {
        toggleActivityIndicator(shown: true)
        databaseRef = Database.database().reference(withPath: "\(pathConsultation)")
        //            guard let vaccineKey = vaccineItem?.key else {
        //                return
        //            }

        var uniqueUUID = consultationKey

        if case .create = typeOfCall {
            uniqueUUID = UUID().uuidString
        }
        if Settings.automaticGenerateEventInCalendarSwitch == true {
            manageEventToCalendar()
        }
        consultationItem = ConsultationItem(
            key: "",
            reason: String(consultationReasonField.text!),
            date: String(consultationDateToSave),
            veterinary: String(selectedVeterinaryKey),
            report: String(consultationReportView.text!),
            weight: String(consultationWeightField.text!),
            idEvent: consultationIdEvent,
            diseases: [])
        let consultationItemRef = databaseRef.child(uniqueUUID)
        consultationItemRef.setValue(consultationItem?.toAnyObject())
        navigationController?.popViewController(animated: true)
    }
    private func toggleActivityIndicator(shown: Bool) {
        activityIndicator.isHidden = !shown
    }
    private func checkConsultationComplete() {
        guard let consultationReason = consultationReasonField.text else {
            return
        }
        guard !consultationReason.isEmpty else {
            return
        }
        guard let consultationDate = consultationDateField.text else {
            return
        }
        guard !consultationDate.isEmpty else {
            return
        }
        guard let consultationVeterinary = consultationVeterinaryField.text else {
            return
        }
        guard !consultationVeterinary.isEmpty else {
            return
        }
        toggleSaveConsultationButton(shown: true)
    }
    private func toggleSaveConsultationButton(shown: Bool) {
        switch shown {
        case true:
            saveConsultationButton.isEnabled = true
        case false:
            saveConsultationButton.isEnabled = false
        }
    saveConsultationButton.isEnabled = shown
    saveConsultationButton.isAccessibilityElement = shown
    }
}
extension ConsultationViewController {
    private func manageEventToCalendar() {
        var veterinaryIndice = 0
        for indice in 0...veterinariesItems.count-1
            where ( selectedVeterinaryKey == veterinariesItems[indice].key) {
                veterinaryIndice = indice
        }
        let store = EKEventStore()
        let event = EKEvent(eventStore: store)
        dateFormatter.dateFormat = "dd MMMM yyyy HH:mm"
        event.title = String(consultationReasonField.text!)
        event.startDate = dateFormatter.date(from: consultationDateField.text!)
        event.endDate = event.startDate + 3600
        event.location = veterinariesItems[veterinaryIndice].veterinaryName
                        + ", "
                        + veterinariesItems[veterinaryIndice].veterinaryStreetOne
                        + ", "
                        + veterinariesItems[veterinaryIndice].veterinaryPostalCode
                        + " "
                        + veterinariesItems[veterinaryIndice].veterinaryCity
        let eventIdentifier = consultationItem?.consultationIdEvent ?? ""
        eventsCalendarManager.addEventToCalendar(event: event, eventIdentifier: eventIdentifier) { (result, idEvent) in
            switch result {
            case .success:
                self.consultationIdEvent = idEvent
                self.updateDictionnaryFieldsUpdated(updated: true, forKey: "consultationIdEventUpdated")
            case .failure(let error):
                switch error {
                case .calendarAccessDeniedOrRestricted:
                    self.getErrors(type: .calendarAccessDeniedOrRestricted)
                case .eventNotAddedToCalendar:
                    self.getErrors(type: .eventNotAddedToCalendar)
                case .eventAlreadyExistsInCalendar:
                    self.getErrors(type: .eventAlreadyExistsInCalendar)
                case .eventDoesntExistInCalendar:
                    self.getErrors(type: .eventDoesntExistInCalendar)
                case .eventNotUpdatedToCalendar:
                    self.getErrors(type: .eventNotUpdatedToCalendar)
                }
            }
        }
    }

    private func createObserverConsultationReason() {
        consultationReasonField?.addTarget(self,
                                         action:
                                                #selector(ConsultationViewController.consultationReasonFieldDidEnd(_:)),
                                         for: .editingDidEnd)
    }
    private func createObserverConsultationDatePickerView() {
        datePickerConsultationDate = UIDatePicker()
        datePickerConsultationDate?.datePickerMode = .dateAndTime
        datePickerConsultationDate?.minuteInterval = 5
        datePickerConsultationDate?.locale = localeLanguage
        datePickerConsultationDate?.addTarget(self,
                                       action:
                                                #selector(ConsultationViewController.dateChangedConsultationDate(datePicker:)),
                                       for: .valueChanged )
        consultationDateField.inputView = datePickerConsultationDate
    }
    private func createObserverConsultationVeterinaryPickerView() {
        pickerViewVeterinary.delegate = self
        consultationVeterinaryField?.addTarget(self,
                                action: #selector(ConsultationViewController.consultationVeterinaryFieldDidEnd(_:)),
                                for: .editingDidEnd )
        consultationVeterinaryField.inputView = pickerViewVeterinary
    }
    private func createObserverConsultationWeight() {
        consultationWeightField?.addTarget(self,
                                         action:
                                                #selector(ConsultationViewController.consultationWeightFieldDidEnd(_:)),
                                         for: .editingDidEnd)
    }
    private func formatDate() {
//        dateFormatter.dateStyle = DateFormatter.Style.full
        dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
//        dateFormatter.timeStyle = DateFormatter.Style.short
    }
}
// MARK: UITextFieldDelegate
extension ConsultationViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        typeFieldOrView = "UITextField"
        activeField = textField
        activeField?.textColor = #colorLiteral(red: 1, green: 0.2730214596, blue: 0.2258683443, alpha: 1)
        lastOffset = view.frame.origin
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        let previousActiveField = activeField
        activeField = textField
        if #available(iOS 13.0, *) {
            activeField?.textColor = UIColor.label
        } else {
            activeField?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        activeField = previousActiveField
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if #available(iOS 13.0, *) {
            activeField?.textColor = UIColor.label
        } else {
            activeField?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        activeField?.resignFirstResponder()
        activeField = nil
        return true
    }
}
// MARK: - UITextViewDelegate
extension ConsultationViewController: UITextViewDelegate {
    internal func textViewDidBeginEditing(_ textView: UITextView) {
        typeFieldOrView = "UITextView"
    }
    internal func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        typeFieldOrView = "UITextView"
        lastOffset = view.frame.origin
        consultationReportView.textColor =  #colorLiteral(red: 1, green: 0.2730214596, blue: 0.2258683443, alpha: 1)
        return true
    }
    internal func textViewDidEndEditing(_ textView: UITextView) {
        if consultationReportView.text != consultationItem?.consultationReport {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "consultationReportUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "consultationReportUpdated")
        }
        if #available(iOS 13.0, *) {
            consultationReportView.textColor = UIColor.label
        } else {
            consultationReportView.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        consultationReportView.resignFirstResponder()
    }
}
// MARK: - extension for UIPickerView
extension ConsultationViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return veterinariesItems.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return veterinariesItems[row].veterinaryName
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedVeterinaryKey = veterinariesItems[row].key
        consultationVeterinaryField.text = veterinariesItems[row].veterinaryName
        //            petVeterinaryField.resignFirstResponder()
    }
}
// MARK: - Keyboard Handling
private extension ConsultationViewController {
    @objc private func keyboardWillShow(notification: NSNotification) {
        if keyboardHeight != nil {
            return
        }
        if !typeFieldOrView.isEmpty {
            if let keyboardSize =
                (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                keyboardHeight = keyboardSize.height
                constraintContentHeight = keyboardHeight + view.frame.size.height
                var distanceToBottom: CGFloat = 0
                if typeFieldOrView == "UITextField" {
                    distanceToBottom =
                        self.view.frame.size.height
                        - (activeField?.frame.origin.y)!
                        - (activeField?.frame.size.height)!
                } else {
                    distanceToBottom =
                        self.view.frame.size.height
                        - (consultationReportView.frame.origin.y)
                        - (consultationReportView.frame.size.height)
                }
                if distanceToBottom > keyboardHeight {
                    return
                }
                //            if distanceToBottom < 0 {
                //                distanceToBottom = 0
                //            }
                let collapseSpace = (keyboardHeight - distanceToBottom + 10)
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame.origin = CGPoint(x: self.lastOffset.x, y: collapseSpace)
                })
            }
        }
    }
    @objc private func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin = CGPoint(x: 0, y: 0)
        }
        keyboardHeight = nil
    }
}
