//
//  ConsultationViewController.swift
//  MDPet
//
//  Created by Philippe on 10/07/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit
import CoreData
import EventKit

class ConsultationViewController: UIViewController {

    @IBOutlet weak var consultationPetNameLabel: UILabel!
    @IBOutlet weak var consultationReasonField: UITextField!
    @IBOutlet weak var consultationDateField: UITextField!
    @IBOutlet weak var consultationVeterinaryField: UITextField!
    @IBOutlet weak var consultationWeightField: UITextField!
    @IBOutlet weak var consultationReportView: UITextView!
    @IBOutlet weak var saveConsultationButton: UIBarButtonItem!
    @IBOutlet weak var suppressConsultationButton: UIButton!

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
    private var selectedVeterinaryObjectID: NSManagedObjectID?
    private var selectedVeterinaryRecordID: String?
    private var typeFieldOrView: String = ""
    private var selectedVeterinaryName = ""
    private var consultationIdEvent = ""
    private var consultationObjectId: NSManagedObjectID?
    private var veterinariesList = VeterinariesItem.fetchAll()
    private var veterinariesItem: [VeterinariesItem] = []
    private var veterinaryItem: VeterinariesItem?
    private var eventsCalendarManager = EventsCalendarManager()
    private var dateItem = ""
    private var dateSelected = ""
    private var consultationDateToSave: Date?
    private var oneFieldHasBeenUpdated = false

    var typeOfCall: TypeOfCall?
    var petItem: PetsItem?
    var consultationItem: ConsultationsItem?

    private var fieldsUpdated: [String: Bool] = [:] {
        didSet {
            oneFieldHasBeenUpdated = false
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
        self.showActivityIndicator(onView: self.view)
        createOrUpdateConsultation()
    }
    @IBAction func suppressConsultation(_ sender: Any) {
        getSuppressedConsultation()
    }
    @IBAction func backToConsultations(_ sender: UIBarButtonItem) {
        activeField?.resignFirstResponder()
        activeField = nil
        checkUpdateConsultationDone()
    }
    @IBAction func veterinaryEditingDidBegin(_ sender: Any) {
        if !consultationVeterinaryField.text!.isEmpty {
            Model.shared.getVeterinaryFromObjectID(
                veterinaryToSearch: selectedVeterinaryObjectID!) { (success, rowVeterinary) in
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
            let calendar = Calendar.current
            let rightNow = Date()
            let interval = 0
            let nextDiff = interval - calendar.component(.minute, from: rightNow)
            let date = calendar.date(byAdding: .minute, value: nextDiff, to: rightNow) ?? Date()
            consultationDateField.text = dateFormatter.string(from: date)
            dateFormatter.dateFormat = dateFormatyyyyMMddHHmm
            consultationDateToSave = date
            datePickerConsultationDate?.date = date
        } else {
            formatDate()
            let consultationDate = dateFormatter.date(from: consultationDateField.text!)
            datePickerConsultationDate?.date = consultationDate!
            dateFormatter.dateFormat = dateFormatyyyyMMddHHmm
            consultationDateToSave = consultationDate!
        }
    }

// MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.locale = localeLanguage
        formatDate()
        createObserverConsultation()
        createDelegateConsultation()
        initiateObserverConsultation()
        veterinariesList = VeterinariesItem.fetchAll()
        if case .update = self.typeOfCall {
            self.initiateConsultationView()
        }
        self.initiateButtonConsultationView()
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
    @objc func isConsultationDeleted(notification: Notification) {
        var hasBeenDeleted = false
        if let object = notification.object as? Bool {
            hasBeenDeleted = object
        }
        if hasBeenDeleted == true {
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
        dateFormatter.dateFormat = dateFormatyyyyMMddWithDashes
        dateSelected = dateFormatter.string(from: datePicker.date)
        dateItem = ""
        if dateSelected != dateItem {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "consultationDateUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "consultationDateUpdated")
        }
        dateFormatter.dateFormat = dateFormatyyyyMMddHHmm
        consultationDateToSave = datePicker.date
        formatDate()
        consultationDateField.text = dateFormatter.string(from: datePicker.date)
    }
    @objc func consultationVeterinaryFieldDidEnd(_ textField: UITextField) {
        selectedVeterinaryName = ""
        if case .update = typeOfCall {
            if consultationItem!.consultationVeterinary != nil {
                Model.shared.getVeterinaryFromRecordID(
                    veterinaryToSearch: consultationItem!.consultationVeterinary!) {(success, veterinaryItem) in
                    if success {
                        self.selectedVeterinaryName = (veterinaryItem?.veterinaryName!)!
                    }
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
}
extension ConsultationViewController {
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
        NotificationCenter.default.addObserver(self, selector: #selector(isConsultationDeleted),
                                               name: .consultationHasBeenDeleted, object: nil)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                              action: #selector(tapGestuireRecognizer(gesture:))))
    }
    private func initiateButtonConsultationView() {
        toggleSaveConsultationButton(shown: false)
        consultationPetNameLabel.text = petItem?.petName
        if case .create = typeOfCall {
            saveConsultationButton.title = addButtonTitle
            self.title = newConsultationTitle
            suppressConsultationButton.isHidden = true
        } else {
            saveConsultationButton.title = OKButtonTitle
            self.title = updateConsultationTitle
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
        consultationObjectId = consultationItem?.objectID
        consultationReasonField.text = consultationItem?.consultationReason
        dateFormatter.dateFormat = dateFormatddMMMMyyyyHHmm
        if consultationItem?.consultationDate != nil {
            consultationDateField.text = dateFormatter.string(from: (consultationItem?.consultationDate)!)
            consultationDateToSave = consultationItem?.consultationDate
        }
        consultationWeightField.text = consultationItem?.consultationWeight
        consultationReportView.text = consultationItem?.consultationReport

        initiateVeterinaryFields()
    }
    private func initiateVeterinaryFields() {
        guard consultationItem!.consultationVeterinary != nil else {
            return
        }

        Model.shared.getVeterinaryFromRecordID(
            veterinaryToSearch: consultationItem!.consultationVeterinary!) {(success, veterinaryItem) in
            if success {
                self.selectedVeterinaryObjectID = veterinaryItem?.objectID
                self.selectedVeterinaryRecordID = veterinaryItem?.veterinaryRecordID
                self.consultationVeterinaryField.text = veterinaryItem?.veterinaryName!
            }
        }
    }
    private func checkUpdateConsultationDone() {
        if oneFieldHasBeenUpdated == false {
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
        if currentReachabilityStatus == .twoG || currentReachabilityStatus == .threeG {
            print("======== connection lente détectée \(currentReachabilityStatus)")
        }
        if case .update = self.typeOfCall {
            let consultationId = consultationItem?.objectID
            let consultationToSave = Model.shared.getObjectByIdConsultation(objectId: consultationId!)
            updateConsultationStorage(consultationToSave: consultationToSave!)
        } else {
            let consultationToSave = ConsultationsItem(context: AppDelegate.viewContext)
            updateConsultationStorage(consultationToSave: consultationToSave)
        }
        navigationController?.popViewController(animated: true)
    }
    private func updateConsultationStorage(consultationToSave: ConsultationsItem) {

        if Settings.automaticGenerateEventInCalendarSwitch == true {
            manageEventToCalendar()
        }

        consultationToSave.consultationReason = String(consultationReasonField.text ?? "")
        if consultationDateToSave != nil {
            consultationToSave.consultationDate = consultationDateToSave
        }
        consultationToSave.consultationVeterinary = selectedVeterinaryRecordID
        var consultationReport = ""
        if consultationReportView.text != "Compte-rendu" {
            consultationReport = String(consultationReportView.text!)
        }
        consultationToSave.consultationReport = consultationReport
        consultationToSave.consultationWeight = String(consultationWeightField.text!)
        consultationToSave.consultationIdEvent = consultationIdEvent
        consultationToSave.consultationPet = petItem?.petRecordID
        do {
        try AppDelegate.viewContext.save()
        } catch {
            print("Error saving consultation")
        }
    }
    private func getSuppressedConsultation() {
        navigationController?.navigationBar.isUserInteractionEnabled = false
        guard let destVC = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmConsultationSuppress")
            as? ConfirmConsultationSuppresViewController else {
                return
        }
        destVC.consultationObjectId = consultationObjectId
        destVC.consultationItem = consultationItem
        self.addChild(destVC)
        destVC.view.frame = self.view.frame
        self.view.addSubview(destVC.view)
        destVC.didMove(toParent: self)
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
        Model.shared.getVeterinaryFromRecordID(
            veterinaryToSearch: selectedVeterinaryRecordID!) {(success, veterinaryItem) in
            if success {
                self.veterinaryItem = veterinaryItem
            }
        }

        let store = EKEventStore()
        let event = EKEvent(eventStore: store)
        dateFormatter.dateFormat = dateFormatddMMMMyyyyHHmm
        event.title = petItem!.petName! + " - " + String(consultationReasonField.text!)
        event.startDate = dateFormatter.date(from: consultationDateField.text!)
        event.endDate = event.startDate + 3600
        var eventLocation: [String] = []
        eventLocation.insert(veterinaryItem!.veterinaryCity!, at: 0)
        eventLocation.insert(veterinaryItem!.veterinaryStreetOne!, at: 0)
        eventLocation.insert(veterinaryItem!.veterinaryName!, at: 0)
        event.location = String((eventLocation as AnyObject).description)

        let eventOne = veterinaryItem!.veterinaryName! + ", "
        let eventTwo = veterinaryItem!.veterinaryStreetOne! + ", "
        let eventThree = String(veterinaryItem!.veterinaryPostalCode!) + " "
            + veterinaryItem!.veterinaryCity!
        event.location = String(eventOne) + String(eventTwo) + String(eventThree)
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
                case .eventNotSuppressedToCalendar:
                    self.getErrors(type: .eventNotSuppressedToCalendar)
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
                                       action: #selector(
                                        ConsultationViewController.dateChangedConsultationDate(datePicker:)),
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
        dateFormatter.dateFormat = dateFormatddMMMyyyyHHmm
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
        if consultationReportView.text == "Compte-rendu" {
            consultationReportView.textColor = UIColor.lightGray
            consultationReportView.font = UIFont(name: "raleway", size: 17.0)
            consultationReportView.returnKeyType = .done
            consultationReportView.delegate = self
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
        return veterinariesList.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return veterinariesList[row].veterinaryName
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        consultationVeterinaryField.text = veterinariesList[row].veterinaryName
        selectedVeterinaryObjectID = veterinariesList[row].objectID
        selectedVeterinaryRecordID = veterinariesList[row].veterinaryRecordID
//        petVeterinaryField.resignFirstResponder()
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
