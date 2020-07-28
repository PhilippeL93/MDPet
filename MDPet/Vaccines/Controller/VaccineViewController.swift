//
//  VaccineViewController.swift
//  MDPet
//
//  Created by Philippe on 26/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit
import Firebase

class VaccineViewController: UIViewController {

    @IBOutlet weak var tableView: SelfSizedTableView!
    @IBOutlet weak var vaccinePetNameLabel: UILabel!
    @IBOutlet weak var vaccineInjectionField: UITextField!
    @IBOutlet weak var vaccineDateField: UITextField!
    @IBOutlet weak var vaccineNameField: UITextField!
    @IBOutlet weak var vaccineVeterinaryField: UITextField!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var saveVaccineButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var vaccineDoneSwitch: UISwitch!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

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
    private var selectedVeterinaryKey: String = ""
    private var petDiseasesCount: Int = 0
    var selectedVeterinaryName = ""

    var veterinariesItems: [VeterinaryItem] = []
    var typeOfCall: String = ""
    var petItem: PetItem?
    var vaccineItem: VaccineItem?
    var imagePicker: ImagePicker!
    private var vaccineKey: String = ""
    private var databaseRef = Database.database().reference(withPath: vaccinesItem)
    private var imageRef = Storage.storage().reference().child(petsInages)
    private var pathVaccine: String = ""
    private var petDiseases: [String] = []
    private var petDiseasesSwitch: [Bool] = []
    private var vaccineDateToSave: String = ""

    private var fieldsUpdated: [String: Bool] = [:] {
        didSet {
            var oneFieldHasBeenUpdated = false
            for (_, hasBeenUpdated) in fieldsUpdated
                where hasBeenUpdated == true {
                    oneFieldHasBeenUpdated = true
            }
            if typeOfCall == "create" {
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
        createOrUpdateVaccine()
    }
    @IBAction func backToVaccines(_ sender: UIBarButtonItem) {
        activeField?.resignFirstResponder()
        activeField = nil
        checkUpdateVaccineDone()
    }
    @IBAction func veterinaryEditingDidBegin(_ sender: Any) {
        if !vaccineVeterinaryField.text!.isEmpty {
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
    @IBAction func vaccineDateEditingDidBegin(_ sender: Any) {
        formatDate()
        if vaccineDateField.text!.isEmpty {
            let date = Date()
            vaccineDateField.text = dateFormatter.string(from: date)
            dateFormatter.dateFormat = "yyyy-MM-dd"
            vaccineDateToSave = dateFormatter.string(from: date)
        } else {
            dateFormatter.dateFormat = "dd MMMM yyyy"
            let vaccineDate = dateFormatter.date(from: vaccineDateField.text!)
            datePickerVaccineDate?.date = vaccineDate!
            dateFormatter.dateFormat = "yyyy-MM-dd"
            vaccineDateToSave = dateFormatter.string(from: vaccineDate!)

        }
    }
    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.locale = localeLanguage
        pathVaccine = UserUid.uid + vaccinesItem + petItem!.key
        databaseRef = Database.database().reference(withPath: "\(pathVaccine)")
        createObserverVaccine()
        createDelegateVaccine()
        initiateObserverVaccine()
        GetFirebaseVeterinaries.shared.observeVeterinaries { (success, veterinariesItems) in
            if success {
                self.veterinariesItems = veterinariesItems
                if self.typeOfCall == "update" {
                    self.initiateVaccineView()
                }
            } else {
                print("erreur")
            }
        }
        initDiseases()
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
    @objc func vaccineInjectionFieldDidEnd(_ textField: UITextField) {
        if vaccineInjectionField.text != vaccineItem?.vaccineInjection {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "vaccineInjectionUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "vaccineInjectionUpdated")
        }
    }
    @objc func dateChangedVaccineDate(datePicker: UIDatePicker) {
        vaccineDateField.text = dateFormatter.string(from: datePicker.date)
        if vaccineDateField.text != vaccineItem?.vaccineDate {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "vaccineDateUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "vaccineDateUpdated")
        }
        dateFormatter.dateFormat = "yyyy-MM-dd"
        vaccineDateToSave = dateFormatter.string(from: datePicker.date)
        formatDate()
        vaccineDateField.text = dateFormatter.string(from: datePicker.date)
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
        if typeOfCall == "update" {
            GetFirebaseVeterinaries.shared.getVeterinaryFromKey(
            veterinaryToSearch: vaccineItem!.vaccineVeterinary) { (success, veterinaryName, _) in
                if success {
                    self.selectedVeterinaryName = veterinaryName
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
    private func createObserverVaccine() {
        createObserverVaccineInjection()
        createObserverDatePickerVaccineDate()
        createObserverVaccineName()
        createObserverVeterinaryPickerView()
        createObserverVaccineDoneSwitch()
    }
    private func createDelegateVaccine() {
        vaccineInjectionField.delegate = self
        vaccineDateField.delegate = self
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
//        NotificationCenter.default.addObserver(self, selector: #selector(isVaccineDeleted),
//                                               name: .hasBeenDeleted, object: nil)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                              action: #selector(tapGestuireRecognizer(gesture:))))
    }
    private func initiateButtonVaccineView() {
        vaccinePetNameLabel.text = petItem?.petName
        toggleActivityIndicator(shown: false)
        toggleSaveVaccineButton(shown: false)
        if typeOfCall == "create" {
            saveVaccineButton.title = "Ajouter"
            self.title = "Nouveau vaccin"
//            suppressVaccineButton.isHidden = true
        } else {
            saveVaccineButton.title = "OK"
            self.title = "Modification vaccin"
        }
    }
    private func initiateVaccineView() {
        initiatePictureView()
        initiateFieldsView()
    }
    private func initiatePictureView() {
        thumbnailImageView.image = nil
        if let URLPicture = vaccineItem?.vaccineURLThumbnail {
            GetFirebasePicture.shared.getPicture(URLPicture: URLPicture) { (success, picture) in
                if success, let picture = picture {
                    self.thumbnailImageView.image = picture
                }
            }
        }
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
        if typeOfCall == "create" {
            vaccineItem = VaccineItem(
                name: "",
                key: "",
                number: 1,
                injection: "",
                date: "",
                URLThumbnail: "",
                veterinary: "",
                diseases: petDiseases,
                switchDiseasess: petDiseasesSwitch,
                done: false)
        }
    }
    private func initiateFieldsView() {
        vaccineKey = vaccineItem?.key ?? ""
        vaccineInjectionField.text = vaccineItem?.vaccineInjection
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let vaccineDate = dateFormatter.date(from: vaccineItem!.vaccineDate)
        dateFormatter.dateFormat = "dd MMMM yyyy"
        vaccineDateField.text = dateFormatter.string(from: vaccineDate!)
        vaccineNameField.text = vaccineItem?.vaccineName
        if vaccineItem?.vaccineDone == true {
            vaccineDoneSwitch.isOn = true
        } else {
            vaccineDoneSwitch.isOn = false
        }
        petDiseasesSwitch = vaccineItem!.vaccineSwitchDiseases
        petDiseases = vaccineItem!.vaccineDiseases

        GetFirebaseVeterinaries.shared.getVeterinaryFromKey(
        veterinaryToSearch: vaccineItem!.vaccineVeterinary) { (success, veterinaryName, _) in
            if success {
                self.vaccineVeterinaryField.text = veterinaryName
            }
        }
        selectedVeterinaryKey = vaccineItem?.vaccineVeterinary ?? ""
    }
    private func toggleActivityIndicator(shown: Bool) {
        activityIndicator.isHidden = !shown
    }
    private func checkUpdateVaccineDone() {
        if saveVaccineButton.isEnabled == false {
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
        databaseRef = Database.database().reference(withPath: "\(pathVaccine)")
        //            guard let vaccineKey = vaccineItem?.key else {
        //                return
        //            }
        var storageRef = imageRef.child("\(String(describing: vaccineKey)).png")
        var uniqueUUID = vaccineKey

        if typeOfCall == "create" {
            uniqueUUID = UUID().uuidString
            storageRef = imageRef.child("\(String(describing: uniqueUUID)).png")
        }

        if let uploadData = self.thumbnailImageView.image?.pngData() {
            storageRef.putData(uploadData, metadata: nil, completion: { (_, error) in
                if let error = error {
                    print(error)
                    return
                }
                storageRef.downloadURL(completion: { (url, err) in
                    if let err = err {
                        print(err)
                        return
                    }
                    let vaccineURLThumbnail = (url?.absoluteString) ?? ""
                    self.updateVaccineStorage(vaccineURLThumbnail: vaccineURLThumbnail, uniqueUUID: uniqueUUID)
                })
            })
        } else {
            updateVaccineStorage(vaccineURLThumbnail: "", uniqueUUID: uniqueUUID)
        }
        navigationController?.popViewController(animated: true)
    }
    private func updateVaccineStorage(vaccineURLThumbnail: String, uniqueUUID: String) {
        toggleActivityIndicator(shown: true)
        vaccineItem = VaccineItem(
            name: String(vaccineNameField.text ?? ""),
            key: "",
            number: 1,
            injection: String(vaccineInjectionField.text ?? ""),
//            date: String(vaccineDateField.text ?? ""),
            date: String(vaccineDateToSave),
            URLThumbnail: vaccineURLThumbnail,
            veterinary: String(selectedVeterinaryKey),
            diseases: petDiseases,
            switchDiseasess: petDiseasesSwitch,
            done: vaccineDoneSwitch.isOn)
        let vaccineItemRef = databaseRef.child(uniqueUUID)
        vaccineItemRef.setValue(vaccineItem?.toAnyObject())
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
        guard let vaccineDate = vaccineDateField.text else {
            return
        }
        guard !vaccineDate.isEmpty else {
            return
        }
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

//    ici
//    private func getSwitchUpdated(switchField: Bool, switchFirebase: Bool) -> Bool {
//        if switchField != switchFirebase {
//            return true
//        } else {
//            return false
//        }
//    }
    private func createObserverVaccineInjection() {
        vaccineInjectionField?.addTarget(self,
                                         action: #selector(VaccineViewController.vaccineInjectionFieldDidEnd(_:)),
                                         for: .editingDidEnd)
    }
    private func createObserverDatePickerVaccineDate() {
        datePickerVaccineDate = UIDatePicker()
        datePickerVaccineDate?.datePickerMode = .date
        datePickerVaccineDate?.locale = localeLanguage
        datePickerVaccineDate?.addTarget(self,
                                       action: #selector(VaccineViewController.dateChangedVaccineDate(datePicker:)),
                                       for: .valueChanged)
        vaccineDateField.inputView = datePickerVaccineDate
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
//        dateFormatter.locale = localeLanguage
        dateFormatter.dateFormat = "dd MMMM yyyy"
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

        let vaccineDisease = vaccineItem?.vaccineDiseases[indexPath.row]
        let vaccineDiseaseSwitch = vaccineItem?.vaccineSwitchDiseases[indexPath.row]
        cell.cellDelegateVaccine = self
        cell.indexSelected = indexPath
        cell.configureVaccineDetailCell(with: vaccineDisease!, vaccineDiseaseSwitch: vaccineDiseaseSwitch!)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (vaccineItem?.vaccineDiseases.count)!
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
        if petDiseasesSwitch[index] != vaccineItem?.vaccineSwitchDiseases[index] {
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
        return veterinariesItems.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return veterinariesItems[row].veterinaryName
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedVeterinaryKey = veterinariesItems[row].key
        vaccineVeterinaryField.text = veterinariesItems[row].veterinaryName
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
            var distanceToBottom: CGFloat = 0
            distanceToBottom =
                self.scrollView.frame.size.height
                - (activeField?.frame.origin.y)!
                - (activeField?.frame.size.height)!
            if distanceToBottom > keyboardHeight {
                return
            }
//            if distanceToBottom < 0 {
//                distanceToBottom = 0
//            }
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
//        let image = image
//        if image != nil {
//
//        } else {
//
//        }
        guard let image = image else {
            return
        }
        self.thumbnailImageView.image = image
        updateDictionnaryFieldsUpdated(updated: true, forKey: "thumbnailImageUpdated")
    }
}
