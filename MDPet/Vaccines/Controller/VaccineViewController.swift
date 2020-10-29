//
//  VaccineViewController.swift
//  MDPet
//
//  Created by Philippe on 26/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit
//import CloudKit
import CoreData

class VaccineViewController: UIViewController {

    @IBOutlet weak var tableView: SelfSizedTableView!
    @IBOutlet weak var vaccinePetNameLabel: UILabel!
    @IBOutlet weak var vaccineInjectionField: UITextField!
//    @IBOutlet weak var vaccineDateField: UITextField!
    @IBOutlet weak var vaccineNameField: UITextField!
    @IBOutlet weak var vaccineVeterinaryField: UITextField!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var saveVaccineButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var vaccineDoneSwitch: UISwitch!
    @IBOutlet weak var suppressVaccineButton: UIButton!
    @IBOutlet weak var vaccineDatePicker: UIDatePicker!

    // MARK: - variables
    private var vaccineInjection: UITextField?
    private var datePickerVaccineDate: UIDatePicker?
    private var vaccineName: UITextField?
    private var pickerViewVeterinary = UIPickerView()
    private var activeField: UITextField?
    private var vaccineDone: UISwitch?
    private var lastOffset: CGPoint!
    private var keyboardHeight: CGFloat!
    private var constraintContentHeight: CGFloat!
    private let localeLanguage = Locale(identifier: "FR-fr")
    private var dateFormatter = DateFormatter()
    private var selectedRace: String = ""
    private var selectedVeterinaryObjectID: NSManagedObjectID?
    private var selectedVeterinaryRecordID: String?
    private var petDiseasesCount: Int = 0
    private var vaccineKey: String = ""
    private var pathVaccine: String = ""
    private var petDiseases: [String] = []
    private var petDiseasesSwitch: [Bool] = []
    private var oneFieldHasBeenUpdated = false
    private var thumbnailImageSelected: UIImage?
    private var dateItem = ""
    private var dateSelected = ""
    private var vaccineDateToSave: Date?
    private var vaccineObjectId: NSManagedObjectID?
    private var petObjectIdString = ""

    var veterinariesList = VeterinariesItem.fetchAll()
    var selectedVeterinaryName = ""
    var veterinariesItem: [VeterinariesItem] = []
    var veterinaryItem: VeterinariesItem?
    var typeOfCall: TypeOfCall?
    var petItem: PetsItem?
    var vaccineItem: VaccinesItem?
    var imagePicker: ImagePicker!
    var toDoStorageManager = ToDoStorageManager()
    var datePicker: UIDatePicker?

    private var fieldsUpdated: [String: Bool] = [:] {
        didSet {
            oneFieldHasBeenUpdated = false
            for (_, hasBeenUpdated) in fieldsUpdated
                where hasBeenUpdated == true {
                    oneFieldHasBeenUpdated = true
            }
            if case .create = typeOfCall {
                toggleSaveVaccineButton(shown: false)
                checkVaccineComplete()
            } else {
                toggleSaveVaccineButton(shown: oneFieldHasBeenUpdated)
            }
        }
    }

    // MARK: - buttons

    @IBAction func addThumbnailButton( _ sender: UIButton) {
        imagePicker.present(from: sender)
    }
    @IBAction func saveVaccine(_ sender: Any) {
        self.showActivityIndicator(onView: self.view)
        createOrUpdateVaccine()
    }
    @IBAction func suppressVaccine(_ sender: Any) {
        getSuppressedVaccine()
    }
    @IBAction func backToVaccines(_ sender: UIBarButtonItem) {
        activeField?.resignFirstResponder()
        activeField = nil
        checkUpdateVaccineDone()
    }
    @IBAction func veterinaryEditingDidBegin(_ sender: Any) {
        if !vaccineVeterinaryField.text!.isEmpty {
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
//    @IBAction func vaccineDateEditingDidBegin(_ sender: Any) {
//        formatDate()
//        if vaccineDateField.text!.isEmpty {
//            let date = Date()
//            vaccineDateField.text = dateFormatter.string(from: date)
//        } else {
//            let vaccineDate = dateFormatter.date(from: vaccineDateField.text!)
//            datePickerVaccineDate?.date = vaccineDate!
//        }
//    }
    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        customDatePicker()
        dateFormatter.locale = localeLanguage
        createObserverVaccine()
        createDelegateVaccine()
        initiateObserverVaccine()
        initDiseases()
        veterinariesList = VeterinariesItem.fetchAll()
        if case .update = self.typeOfCall {
            self.initiateVaccineView()
        }

        initiateButtonVaccineView()
        imagePicker = ImagePicker(presentationController: self, delegate: self)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.maxHeight = CGFloat(44 * petDiseasesCount)
        tableView.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .navigationBarVaccineToTrue, object: nil)
        NotificationCenter.default.removeObserver(self, name: .vaccineIsToUpdate, object: nil)
        NotificationCenter.default.removeObserver(self, name: .vaccineHasBeenDeleted, object: nil)
    }
    // MARK: - @objc func
    @objc func tapGestuireRecognizer(gesture: UIGestureRecognizer) {
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
    }
    @objc func navigationBarVaccineToTrue(notification: Notification) {
        navigationController?.navigationBar.isUserInteractionEnabled = true
    }
    @objc func isVaccineToUpdate(notification: Notification) {
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
    @objc func isVaccineDeleted(notification: Notification) {
        var hasBeenDeleted = false
        if let object = notification.object as? Bool {
            hasBeenDeleted = object
        }
        if hasBeenDeleted == true {
            navigationController?.popViewController(animated: true)
            return
        }
    }
    @objc func vaccineInjectionFieldDidEnd(_ textField: UITextField) {
        if vaccineInjectionField.text != vaccineItem?.vaccineInjection {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "vaccineInjectionUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "vaccineInjectionUpdated")
        }
    }
//    @objc func dateChangedVaccineDate(datePicker: UIDatePicker) {
//        vaccineDateField.text = dateFormatter.string(from: datePicker.date)
//        dateFormatter.dateFormat = dateFormatyyyyMMddWithDashes
//        dateSelected = dateFormatter.string(from: datePicker.date)
//        dateItem = ""
//        if vaccineItem?.vaccineDate != nil {
//            dateItem = dateFormatter.string(from: (vaccineItem?.vaccineDate)!)
//        }
//        if dateSelected != dateItem {
//            updateDictionnaryFieldsUpdated(updated: true, forKey: "vaccineDateUpdated")
//        } else {
//            updateDictionnaryFieldsUpdated(updated: false, forKey: "vaccineDateUpdated")
//        }
//        formatDate()
//    }
    @objc func vaccineDateChanged() {
//        guard let datePickerOne = consultationDatePicker else {
//            return
//        }
//        print("'=============== datePicker \(consultationDatePicker.date)")
//        guard let datePickerTwo = datePicker else {
//            return
//        }
//        print("'=============== datePickerBis \(datePicker!.date)")
        dateFormatter.dateFormat = dateFormatyyyyMMddHHmm
        dateSelected = dateFormatter.string(from: vaccineDatePicker!.date)
        dateItem = ""
        if vaccineItem?.vaccineDate != nil {
            dateItem = dateFormatter.string(from: (vaccineItem?.vaccineDate)!)
        }
        if dateSelected != dateItem {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "vaccineDateUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "vaccineDateUpdated")
        }
        vaccineDateToSave = vaccineDatePicker?.date
    }
    @objc func vaccineNameFieldDidEnd(_ textField: UITextField) {
        if vaccineNameField.text != vaccineItem?.vaccineName {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "vaccineNameUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "vaccineNameUpdated")
        }
    }
    @objc func vaccineVeterinaryFieldDidEnd(_ textField: UITextField) {
        selectedVeterinaryName = ""
        if case .update = typeOfCall {
            if vaccineItem!.vaccineVeterinary != nil {
                Model.shared.getVeterinaryFromRecordID(
                    veterinaryToSearch: vaccineItem!.vaccineVeterinary!) { (success, veterinaryItem) in
                    if success {
                        self.selectedVeterinaryName = veterinaryItem!.veterinaryName!
                    }
                }
            }
        }
        if vaccineVeterinaryField.text != selectedVeterinaryName {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "vaccineVeterinaryUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "vaccineVeterinaryUpdated")
        }
    }
    @objc func vaccineDoneSwitchDidChange(_ textField: UISwitch) {
        if vaccineDoneSwitch.isOn != vaccineItem?.vaccineDone {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "vaccineDoneSwitchUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "vaccineDoneSwitchUpdated")
        }
    }
    private func updateDictionnaryFieldsUpdated(updated: Bool, forKey: String) {
        fieldsUpdated.updateValue(updated, forKey: forKey)
    }
}
extension VaccineViewController {
    // MARK: - functions
    func customDatePicker() {
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.date = Date()
        //        datePicker?.locale = .current
        datePicker?.locale = localeLanguage
        datePicker?.preferredDatePickerStyle = .compact
        vaccineDatePicker?.tintColor = UIColor.systemGray
        vaccineDatePicker?.backgroundColor = UIColor.systemBackground
    }
    private func createObserverVaccine() {
        createObserverVaccineInjection()
//        createObserverDatePickerVaccineDate()
        createObserverVaccineDatePicker()
        createObserverVaccineName()
        createObserverVeterinaryPickerView()
        createObserverVaccineDoneSwitch()
    }
    private func createDelegateVaccine() {
        vaccineInjectionField.delegate = self
//        vaccineDateField.delegate = self
        vaccineNameField.delegate = self
        vaccineVeterinaryField.delegate = self
    }
    private func initiateObserverVaccine() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(navigationBarVaccineToTrue),
                                               name: .navigationBarVaccineToTrue, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(isVaccineToUpdate),
                                               name: .vaccineIsToUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(isVaccineDeleted),
                                               name: .vaccineHasBeenDeleted, object: nil)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                              action: #selector(tapGestuireRecognizer(gesture:))))
    }
    private func initiateButtonVaccineView() {
        vaccinePetNameLabel.text = petItem?.petName
        toggleSaveVaccineButton(shown: false)
        if case .create = typeOfCall {
            saveVaccineButton.title = addButtonTitle
            self.title = newVaccineTitle
            suppressVaccineButton.isHidden = true
        } else {
            saveVaccineButton.title = OKButtonTitle
            self.title = updateVaccinTitle
        }
    }
    private func initiateVaccineView() {
        initiatePictureView()
        initiateFieldsView()
    }
    private func initiatePictureView() {
        guard let imageData = vaccineItem?.vaccineThumbnail else {
            return
        }
        thumbnailImageView.image = UIImage(data: imageData)
    }
    private func initDiseases() {
        switch petItem?.petType {
        case 0:
            petDiseases = catDiseases
            petDiseasesSwitch = catDiseasesSwitch
            petDiseasesCount = catDiseases.count
        case 1:
            petDiseases = dogDiseases
            petDiseasesSwitch = dogDiseasesSwitch
            petDiseasesCount = dogDiseases.count
        case 2:
            petDiseases = rabbitDiseases
            petDiseasesSwitch = rabbitDiseasesSwitch
            petDiseasesCount = rabbitDiseases.count
        default:
            petDiseasesCount = 0
        }
    }
    private func initiateFieldsView() {
        vaccineObjectId = vaccineItem?.objectID
        vaccineInjectionField.text = vaccineItem?.vaccineInjection
        dateFormatter.dateFormat = dateFormatddMMMMyyyyWithSpaces
        if vaccineItem!.vaccineDate != nil {
            vaccineDateToSave = vaccineItem?.vaccineDate
//            vaccineDateField.text = dateFormatter.string(from: vaccineItem!.vaccineDate!)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
            dateFormatter.locale = localeLanguage
            let dateString = dateFormatter.string(from: (vaccineItem?.vaccineDate)!)

            let date = dateFormatter.date(from: dateString)
            vaccineDatePicker?.setDate(date!, animated: false)
            datePicker?.setDate(date!, animated: false)
        }
        vaccineNameField.text = vaccineItem?.vaccineName
        if vaccineItem?.vaccineDone == true {
            vaccineDoneSwitch.isOn = true
        } else {
            vaccineDoneSwitch.isOn = false
        }
        petDiseasesSwitch = vaccineItem!.vaccineSwitchDiseases!
        petDiseases = vaccineItem!.vaccineDiseases!
        tableView.reloadData()

        initiateVeterinaryFields()
    }
    private func initiateVeterinaryFields() {
        guard vaccineItem?.vaccineVeterinary != nil else {
            return
        }
        Model.shared.getVeterinaryFromRecordID(
            veterinaryToSearch: vaccineItem!.vaccineVeterinary!) { (success, veterinaryItem) in
            if success {
                self.selectedVeterinaryRecordID = veterinaryItem?.veterinaryRecordID
                self.selectedVeterinaryObjectID = veterinaryItem?.objectID
                self.vaccineVeterinaryField.text = veterinaryItem?.veterinaryName!
            }
        }
    }
    private func getSuppressedVaccine() {
        navigationController?.navigationBar.isUserInteractionEnabled = false
        guard let destVC = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmVaccineSuppress")
            as? ConfirmVaccineSuppressViewController else {
                return
        }
        destVC.vaccineObjectId = vaccineObjectId
        self.addChild(destVC)
        destVC.view.frame = self.view.frame
        self.view.addSubview(destVC.view)
        destVC.didMove(toParent: self)
    }
    private func checkUpdateVaccineDone() {
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
        destVC.typeOfCaller = TypeOfCaller.vaccine
        destVC.view.frame = self.view.frame
        self.view.addSubview(destVC.view)
        destVC.didMove(toParent: self)
    }
    private func createOrUpdateVaccine() {
        if case .update = self.typeOfCall {
            let vaccineId = vaccineItem?.objectID
            let vaccineToSave = Model.shared.getObjectByIdVaccine(objectId: vaccineId!)
            updateVaccineStorage(vaccineToSave: vaccineToSave!)
        } else {
            let vaccineToSave = VaccinesItem(context: AppDelegate.viewContext)
            updateVaccineStorage(vaccineToSave: vaccineToSave)
        }
        navigationController?.popViewController(animated: true)
    }
    private func updateVaccineStorage(vaccineToSave: VaccinesItem) {
        vaccineToSave.vaccineInjection = String(vaccineInjectionField.text ?? "")
        vaccineToSave.vaccineName = String(vaccineNameField.text ?? "")
//        if !vaccineDateField.text!.isEmpty {
//            vaccineToSave.vaccineDate = dateFormatter.date(from: vaccineDateField.text ?? "")
//        }
        if vaccineDateToSave != nil {
            vaccineToSave.vaccineDate = vaccineDateToSave
        }
        if thumbnailImageSelected != nil {
            let imageData = thumbnailImageView.image?.pngData()
            vaccineToSave.vaccineThumbnail = imageData
        }
        vaccineToSave.vaccineVeterinary = selectedVeterinaryRecordID
        vaccineToSave.vaccineDiseases = petDiseases
        vaccineToSave.vaccineSwitchDiseases = petDiseasesSwitch
        vaccineToSave.vaccineDone = vaccineDoneSwitch.isOn
        vaccineToSave.vaccinePet = petItem?.petRecordID
//        toDoStorageManager.save()
        try? AppDelegate.viewContext.save()
    }
    private func checkVaccineComplete() {
        guard let vaccineInjection = vaccineInjectionField.text else {
            return
        }
        guard !vaccineInjection.isEmpty else {
            return
        }
        guard let vaccineName = vaccineNameField.text else {
            return
        }
        guard !vaccineName.isEmpty else {
            return
        }
//        guard let vaccineDate = vaccineDateField.text else {
//            return
//        }
        guard vaccineDatePicker != nil else {
            return
        }
//        guard !vaccineDate.isEmpty else {
//            return
//        }
        guard let vaccineVeterinary = vaccineVeterinaryField.text else {
            return
        }
        guard !vaccineVeterinary.isEmpty else {
            return
        }
        toggleSaveVaccineButton(shown: true)
    }
    private func toggleSaveVaccineButton(shown: Bool) {
        switch shown {
        case true:
            saveVaccineButton.isEnabled = true
        case false:
            saveVaccineButton.isEnabled = false
        }
    saveVaccineButton.isEnabled = shown
    saveVaccineButton.isAccessibilityElement = shown
    }
    private func createObserverVaccineInjection() {
        vaccineInjectionField?.addTarget(self,
                                         action: #selector(VaccineViewController.vaccineInjectionFieldDidEnd(_:)),
                                         for: .editingDidEnd)
    }
    private func createObserverVaccineDatePicker() {
        vaccineDatePicker?.addTarget(self,
                                          action: #selector(vaccineDateChanged),
                                          for: .valueChanged)
    }
    private func createObserverVaccineName() {
        vaccineNameField?.addTarget(self,
                                         action: #selector(VaccineViewController.vaccineNameFieldDidEnd(_:)),
                                         for: .editingDidEnd)
    }
    private func createObserverVeterinaryPickerView() {
        pickerViewVeterinary.delegate = self
        vaccineVeterinaryField?.addTarget(self,
                                action: #selector(VaccineViewController.vaccineVeterinaryFieldDidEnd(_:)),
                                for: .editingDidEnd )
        vaccineVeterinaryField.inputView = pickerViewVeterinary
    }
    private func createObserverVaccineDoneSwitch() {
        vaccineDoneSwitch?.addTarget(self,
                                     action: #selector(VaccineViewController.vaccineDoneSwitchDidChange(_:)),
                                     for: .touchUpInside)
    }
    private func formatDate() {
        dateFormatter.dateFormat = dateFormatddMMMMyyyyWithSpaces
    }
}

// MARK: - extension Data for tableView
extension VaccineViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemVaccineDetail", for: indexPath)
            as? PresentVaccineDetailCell else {
            return UITableViewCell()
        }
        let vaccineDisease = petDiseases[indexPath.row]
        let vaccineDiseaseSwitch = petDiseasesSwitch[indexPath.row]
        cell.cellDelegateVaccine = self
        cell.indexSelected = indexPath
        cell.configureVaccineDetailCell(with: vaccineDisease, vaccineDiseaseSwitch: vaccineDiseaseSwitch)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petDiseases.count
    }

}
// MARK: - extension Delegate
extension VaccineViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let size = tableView.frame.height / 8
        return size
    }
}
// MARK: - extension Delegate protocol
extension VaccineViewController: TableViewClickVaccine {
    func onClickCellVaccine(index: Int, switchDisease: Bool) {
        petDiseasesSwitch[index] =  switchDisease
        let fieldToUpdated = "vaccineSwitchDiseases" + String(index) + "Updated"
        if petDiseasesSwitch[index] != vaccineItem?.vaccineSwitchDiseases![index] {
            updateDictionnaryFieldsUpdated(updated: true, forKey: fieldToUpdated)
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: fieldToUpdated)
        }
    }
}
// MARK: - UITextFieldDelegate
extension VaccineViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        activeField?.textColor = #colorLiteral(red: 1, green: 0.2730214596, blue: 0.2258683443, alpha: 1)
        lastOffset = self.scrollView.contentOffset
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
        activeField?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        activeField?.resignFirstResponder()
        activeField = nil
        return true
    }
}
// MARK: - extension for UIPickerView
extension VaccineViewController: UIPickerViewDataSource, UIPickerViewDelegate {
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
        vaccineVeterinaryField.text = veterinariesList[row].veterinaryName
        selectedVeterinaryObjectID = veterinariesList[row].objectID
        selectedVeterinaryRecordID = veterinariesList[row].veterinaryRecordID
        //            petVeterinaryField.resignFirstResponder()
    }
}
// MARK: - Keyboard Handling
private extension VaccineViewController {
    @objc private func keyboardWillShow(notification: NSNotification) {
        if keyboardHeight != nil {
            return
        }
        if let keyboardSize =
            (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
            constraintContentHeight = keyboardHeight + view.frame.size.height
            let distanceToBottom =
                self.scrollView.frame.size.height
                - (activeField?.frame.origin.y)!
                - (activeField?.frame.size.height)!
            if distanceToBottom > keyboardHeight {
                return
            }
            let collapseSpace = (keyboardHeight - distanceToBottom + 10)
            UIView.animate(withDuration: 0.3, animations: {
                self.scrollView.contentOffset = CGPoint(x: self.lastOffset.x, y: collapseSpace)
            })
        }
    }
    @objc private func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
            self.scrollView.contentOffset = self.lastOffset
        }
        keyboardHeight = nil
    }
}
extension VaccineViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        guard let image = image else {
            return
        }
        self.thumbnailImageView.image = image
        thumbnailImageSelected = image
        updateDictionnaryFieldsUpdated(updated: true, forKey: "thumbnailImageUpdated")
    }
}
