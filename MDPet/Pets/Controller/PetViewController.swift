//
//  PetViewController.swift
//  MDPet
//
//  Created by Philippe on 18/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit
import CoreData

class PetViewController: UIViewController {

    @IBOutlet weak var petTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var petPicture: UIImageView!
    @IBOutlet weak var petNameField: UITextField!
    @IBOutlet weak var petGenderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var petBirthDateField: UITextField!
    @IBOutlet weak var petRaceField: UITextField!
    @IBOutlet weak var petColorField: UITextField!
    @IBOutlet weak var petParticularSignsField: UITextField!
    @IBOutlet weak var petVeterinaryField: UITextField!
    @IBOutlet weak var petTatooField: UITextField!
    @IBOutlet weak var petSterilizedSwitch: UISwitch!
    @IBOutlet weak var petSterilizedDateField: UITextField!
    @IBOutlet weak var petWeaningSwitch: UISwitch!
    @IBOutlet weak var petWeaningDateField: UITextField!
    @IBOutlet weak var petDeathDateField: UITextField!
    @IBOutlet weak var petBreederView: UITextView!
    @IBOutlet weak var petURLBreederField: UITextField!
    @IBOutlet weak var petPedigreeSwitch: UISwitch!
    @IBOutlet weak var petPedigreeNumberField: UITextField!
    @IBOutlet weak var petMotherNameField: UITextField!
    @IBOutlet weak var petFatherNameField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var savePetButton: UIBarButtonItem!
    @IBOutlet weak var suppressPetButton: UIButton!
    @IBOutlet weak var vaccinesButton: UIButton!
    @IBOutlet weak var consultationsButton: UIButton!
    @IBOutlet weak var petCallPhoneField: UIButton!

    // MARK: - variables
    private var pickerViewGender = UIPickerView()
    private var datePickerBirthDate: UIDatePicker?
    private var petSterilized: UISwitch?
    private var datePickerSterilizedDate: UIDatePicker?
    private var petWeaning: UISwitch?
    private var datePickerWeaningDate: UIDatePicker?
    private var datePickerDeathDate: UIDatePicker?
    private var pickerViewVeterinary = UIPickerView()
    private var pickerViewRace = UIPickerView()
    private var petPedigree: UISwitch?
    private var activeField: UITextField?
    private var lastOffset: CGPoint!
    private var keyboardHeight: CGFloat!
    private var constraintContentHeight: CGFloat!
    private let localeLanguage = Locale(identifier: "FR-fr")
    private var dateFormatter = DateFormatter()
    private var selectedRace: String = ""
    private var selectedVeterinaryObjectID: NSManagedObjectID?
    private var selectedVeterinaryRecordID: String?
    private var typeFieldOrView: String = ""
    private var selectedVeterinaryName = ""

    private var veterinariesItem: [VeterinariesItem] = []
    private var oneFieldHasBeenUpdated = false
    private var petImageSelected: UIImage?
    private var dateItem = ""
    private var dateSelected = ""
    private var petObjectId: NSManagedObjectID?
    var veterinariesList = VeterinariesItem.fetchAll()
    var typeOfCall: TypeOfCall?
    var petItem: PetsItem?
    var imagePicker: ImagePicker!
    var toDoStorageManager = ToDoStorageManager()
    var datePicker: UIDatePicker?

    private var fieldsUpdated: [String: Bool] = [:] {
        didSet {
            if case .create = typeOfCall {
                checkPetComplete()
            } else {
                oneFieldHasBeenUpdated = false
                for (_, hasBeenUpdated) in fieldsUpdated
                where hasBeenUpdated == true {
                    oneFieldHasBeenUpdated = true
                }
                if oneFieldHasBeenUpdated == true {
                    checkPetComplete()
                } else {
                    toggleSavePetButton(shown: oneFieldHasBeenUpdated)
                }
            }
        }
    }
// MARK: - buttons
    @IBAction func addPetPhoto(_ sender: UIButton) {
        imagePicker.present(from: sender)
    }
    @IBAction func savePet(_ sender: Any) {
        self.showActivityIndicator(onView: self.view)
        createOrUpdatePet()
    }
    @IBAction func suppressPet(_ sender: Any) {
        getSuppressedPet()
    }
    @IBAction func backToPets(_ sender: UIBarButtonItem) {
        activeField?.resignFirstResponder()
        activeField = nil
        checkUpdatePetDone()
    }
    @IBAction func vaccineButtom(_ sender: Any) {
        getVaccines()
    }
    @IBAction func consultationsButton(_ sender: Any) {
        getConsultations()
    }
    @IBAction func callVeterinary(_ sender: Any) {
        callVeterinary()
    }
    @IBAction func veterinaryEditingDidBegin(_ sender: Any) {
        if !petVeterinaryField.text!.isEmpty {
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
    @IBAction func raceEditingDidBegin(_ sender: Any) {
        let rowRaces = getRowRaceFromKey(raceToSearch: petRaceField.text!)
        pickerViewRace.selectRow(rowRaces, inComponent: 0, animated: true)
    }
    @IBAction func birthDateEditingDidBegin(_ sender: Any) {
        formatDate()
        if petBirthDateField.text!.isEmpty {
            let date = Date()
            petBirthDateField.text = dateFormatter.string(from: date)
        } else {
            let birthDate = dateFormatter.date(from: petBirthDateField.text!)
            datePickerBirthDate?.date = birthDate!
        }
    }
    @IBAction func sterilizedDateEditingDidBegin(_ sender: Any) {
        guard petSterilizedSwitch.isOn else {
            return
        }
        formatDate()
        if petSterilizedDateField.text!.isEmpty {
            let date = Date()
            petSterilizedDateField.text = dateFormatter.string(from: date)
        } else {
            let sterilizedDate = dateFormatter.date(from: petSterilizedDateField.text!)
            datePickerSterilizedDate?.date = sterilizedDate!
        }
    }
    @IBAction func weaningDateEditingDidBegin(_ sender: Any) {
        guard petWeaningSwitch.isOn else {
            return
        }
        formatDate()
        if petWeaningDateField.text!.isEmpty {
            let date = Date()
            petWeaningDateField.text = dateFormatter.string(from: date)
        } else {
            let weaningDate = dateFormatter.date(from: petWeaningDateField.text!)
            datePickerWeaningDate?.date = weaningDate!
        }
    }
    @IBAction func deathDateEditingDidBegin(_ sender: Any) {
        formatDate()
        if petDeathDateField.text!.isEmpty {
            let date = Date()
            petDeathDateField.text = dateFormatter.string(from: date)
        } else {
            let deathDate = dateFormatter.date(from: petDeathDateField.text!)
            datePickerDeathDate?.date = deathDate!
        }
    }
// MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        customDatePicker()
        createObserverPet()
        createDelegatePet()
        initiateObserverPet()
        veterinariesList = VeterinariesItem.fetchAll()
        if case .update = self.typeOfCall {
            self.initiatePetView()
        }
        self.initiateButtonSwitchViewPet()
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .navigationBarPetToTrue, object: nil)
        NotificationCenter.default.removeObserver(self, name: .petIsToUpdate, object: nil)
        NotificationCenter.default.removeObserver(self, name: .petHasBeenDeleted, object: nil)
    }
}
extension PetViewController {
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
                petBreederView.textColor = UIColor.label
            } else {
                petBreederView.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            }
            petBreederView.resignFirstResponder()
        }
        typeFieldOrView = ""
    }
    @objc func navigationBarPetToTrue(notification: Notification) {
        navigationController?.navigationBar.isUserInteractionEnabled = true
    }
    @objc func isPetToUpdate(notification: Notification) {
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
    @objc func isPetDeleted(notification: Notification) {
        var hasBeenDeleted = false
        if let object = notification.object as? Bool {
            hasBeenDeleted = object
        }
        if hasBeenDeleted == true {
            navigationController?.popViewController(animated: true)
        }
    }
    @objc func textChangedPetTypeSegmentedCtrl(typeSegmentedCtrl: UISegmentedControl) {
        if petItem?.petType == nil {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "petTypeUpdated")
            petRaceField.text = ""
            self.pickerViewRace.reloadAllComponents()
            guard let petType =
                    petTypeSegmentedControl.titleForSegment(at: petTypeSegmentedControl.selectedSegmentIndex) else {
                return
            }
            if case .update = typeOfCall {
                if petType == "Rongeur" {
                    vaccinesButton.isHidden = true
                } else {
                    vaccinesButton.isHidden = false
                }
            }
            return
        }
        if petTypeSegmentedControl.selectedSegmentIndex != Int(petItem!.petType) {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "petTypeUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "petTypeUpdated")
        }
        petRaceField.text = ""
        self.pickerViewRace.reloadAllComponents()
        guard let petType =
                petTypeSegmentedControl.titleForSegment(at: petTypeSegmentedControl.selectedSegmentIndex) else {
            return
        }
        if case .update = typeOfCall {
            if petType == "Rongeur" {
                vaccinesButton.isHidden = true
            } else {
                vaccinesButton.isHidden = false
            }
        }
    }
    @objc func petNameFieldDidEnd(_ textField: UITextField) {
        if petNameField.text != petItem?.petName {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "petNameUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "petNameUpdated")
        }
    }
    @objc func textChangedPetGenderSegmentedCtrl(genderSegmentedCtrl: UISegmentedControl) {
        if petItem?.petGender == nil {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "petGenderUpdated")
            return
        }
        if petGenderSegmentedControl.selectedSegmentIndex != Int(petItem!.petGender) {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "petGenderUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "petGenderUpdated")
        }
        self.pickerViewGender.reloadAllComponents()
    }
    @objc func birthDateValueChanged(datePicker: UIDatePicker) {
        petBirthDateField.text = dateFormatter.string(from: datePicker.date)
        dateFormatter.dateFormat = dateFormatyyyyMMddWithDashes
        dateSelected = dateFormatter.string(from: datePicker.date)
        dateItem = ""
        if petItem?.petBirthDate != nil {
            dateItem = dateFormatter.string(from: (petItem?.petBirthDate)!)
        }
        if dateSelected != dateItem {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "petBirthDateUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "petBirthDateUpdated")
        }
        formatDate()
    }
    @objc func petTatooFieldDidEnd(_ textField: UITextField) {
        if petTatooField.text != petItem?.petTatoo {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "petTatooUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "petTatooUpdated")
        }
    }
    @objc func petSterilizedSwitchDidChange(_ textField: UISwitch) {
        if petSterilizedSwitch.isOn == true {
            petSterilizedDateField.isEnabled = true
        } else {
            petSterilizedDateField.isEnabled = false
            petSterilizedDateField.text =  ""
        }
        if petSterilizedSwitch.isOn != petItem?.petSterilized {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "petSterilizedSwitchUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "petSterilizedSwitchUpdated")
            updateDictionnaryFieldsUpdated(updated: false, forKey: "petSterilizedDateUpdated")
        }
    }
    @objc func dateChangedSterilized(datePicker: UIDatePicker) {
        petSterilizedDateField.text = dateFormatter.string(from: datePicker.date)
    }
    @objc func dateChangedSterilizedField(_ textField: UITextField) {
        dateSelected = ""
        if !petSterilizedDateField.text!.isEmpty {
            dateFormatter.dateFormat = dateFormatddMMMMyyyyWithSpaces
            let dateTest = dateFormatter.date(from: petSterilizedDateField.text!)
            dateFormatter.dateFormat = dateFormatyyyyMMddWithDashes
            dateSelected = dateFormatter.string(from: dateTest!)
        }
        dateItem = ""
        if petItem?.petSterilizedDate != nil {
            dateItem = dateFormatter.string(from: (petItem?.petSterilizedDate)!)
        }
        if dateSelected != dateItem {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "petSterilizedDateUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "petSterilizedDateUpdated")
        }
        formatDate()
    }
    @objc func petVeterinaryFieldDidEnd(_ textField: UITextField) {
        selectedVeterinaryName = ""
        if case .update = typeOfCall {
            if petItem!.petVeterinary != nil {
                Model.shared.getVeterinaryFromRecordID(
                    veterinaryToSearch: petItem!.petVeterinary!) { (success, veterinaryItem) in
                    if success {
                        self.selectedVeterinaryName = veterinaryItem!.veterinaryName!
                    }
                }
            }
        }
        if petVeterinaryField.text != selectedVeterinaryName {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "petVeterinaryUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "petVeterinaryUpdated")
        }
        petCallPhoneField.isHidden = true
        if !petVeterinaryField.text!.isEmpty {
            if currentPhoneStatus == .phoneUsable {
                Model.shared.getVeterinaryFromRecordID(
                    veterinaryToSearch: selectedVeterinaryRecordID!) { (success, veterinaryItem) in
                    if success {
                        if !veterinaryItem!.veterinaryPhone!.isEmpty {
                            self.petCallPhoneField.isHidden = false
                        }
                    }
                }
            }
        } else {
            selectedVeterinaryRecordID = ""
        }
    }
    @objc func petRaceFieldDidEnd(_ textField: UITextField) {
        if petRaceField.text != petItem?.petRace {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "petRaceUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "petRaceUpdated")
        }
    }
    @objc func petColorFieldDidEnd(_ textField: UITextField) {
        if petColorField.text != petItem?.petColor {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "petColorUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "petColorUpdated")
        }
    }
    @objc func petParticularSignsFieldDidEnd(_ textField: UITextField) {
        if petParticularSignsField.text != petItem?.petParticularSigns {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "petParticularSignsUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "petParticularSignsUpdated")
        }
    }
    @objc func petWeaningSwitchDidChange(_ textField: UISwitch) {
        if petWeaningSwitch.isOn == true {
            petWeaningDateField.isEnabled = true
        } else {
            petWeaningDateField.isEnabled = false
            petWeaningDateField.text =  ""
        }
        if petWeaningSwitch.isOn != petItem?.petWeaning {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "petWeaningSwitchUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "petWeaningSwitchUpdated")
            updateDictionnaryFieldsUpdated(updated: false, forKey: "petWeaningDateUpdated")
        }
    }
    @objc func dateChangedWeaning(datePicker: UIDatePicker) {
        petWeaningDateField.text = dateFormatter.string(from: datePicker.date)
    }
    @objc func dateChangedWeaningField(_ textField: UITextField) {
        dateSelected = ""
        if !petWeaningDateField.text!.isEmpty {
            dateFormatter.dateFormat = dateFormatddMMMMyyyyWithSpaces
            let dateTest = dateFormatter.date(from: petWeaningDateField.text!)
            dateFormatter.dateFormat = dateFormatyyyyMMddWithDashes
            dateSelected = dateFormatter.string(from: dateTest!)
        }
        dateItem = ""
        if petItem?.petWeaningDate != nil {
            dateItem = dateFormatter.string(from: (petItem?.petWeaningDate)!)
        }
        if dateSelected != dateItem {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "petWeaningDateUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "petWeaningDateUpdated")
        }
        formatDate()
    }
    @objc func dateChangedDeathDate(datePicker: UIDatePicker) {
        petDeathDateField.text = dateFormatter.string(from: datePicker.date)
        dateSelected = dateFormatter.string(from: datePicker.date)
        dateItem = ""
        if petItem?.petDeathDate != nil {
            dateItem = dateFormatter.string(from: (petItem?.petDeathDate)!)
        }
        if dateSelected != dateItem {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "petDeathDateUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "petDeathDateUpdated")
        }
        formatDate()
    }
    @objc func dateChangedDeathField(_ textField: UITextField) {
        dateSelected = ""
        if !petDeathDateField.text!.isEmpty {
            dateFormatter.dateFormat = dateFormatddMMMMyyyyWithSpaces
            let dateTest = dateFormatter.date(from: petDeathDateField.text!)
            dateFormatter.dateFormat = dateFormatyyyyMMddWithDashes
            dateSelected = dateFormatter.string(from: dateTest!)
        }
        dateItem = ""
        if petItem?.petDeathDate != nil {
            dateItem = dateFormatter.string(from: (petItem?.petDeathDate)!)
        }
        if dateSelected != dateItem {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "petDeathDateUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "petDeathDateUpdated")
        }
        formatDate()
    }
    @objc func petPedigreeSwitchDidChange(_ textField: UISwitch) {
        if petPedigreeSwitch.isOn == true {
            petPedigreeNumberField.isEnabled = true
            petPedigreeNumberField.text = petItem?.petPedigreeNumber
            petMotherNameField.isEnabled = true
            petMotherNameField.text = petItem?.petMotherName
            petFatherNameField.isEnabled = true
            petFatherNameField.text = petItem?.petFatherName
        } else {
            petPedigreeNumberField.isEnabled = false
            petPedigreeNumberField.text =  ""
            petMotherNameField.isEnabled = false
            petMotherNameField.text = ""
            petFatherNameField.isEnabled = false
            petFatherNameField.text = ""
        }
        if petPedigreeSwitch.isOn != petItem?.petPedigree {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "petPedigreeSwitchUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "petPedigreeSwitchUpdated")
        }
    }
    @objc func petURLBreederFieldDidEnd(_ textField: UITextField) {
        if petURLBreederField.text != petItem?.petURLBreeder {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "petURLBreederUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "petURLBreederUpdated")
        }
    }
    @objc func petPedigreeNumberFieldDidEnd(_ textField: UITextField) {
        if petPedigreeNumberField.text != petItem?.petPedigreeNumber {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "petPedigreeNumberUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "petPedigreeNumberUpdated")
        }
    }
    @objc func petMotherNameFieldDidEnd(_ textField: UITextField) {
        if petMotherNameField.text != petItem?.petMotherName {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "petMotherNameUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "petMotherNameUpdated")
        }
    }
    @objc func petFatherNameFieldDidEnd(_ textField: UITextField) {
        if petFatherNameField.text != petItem?.petFatherName {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "petFatherNameUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "petFatherNameUpdated")
        }
    }
    private func formatDate() {
        dateFormatter.locale = localeLanguage
        dateFormatter.dateFormat = dateFormatddMMMMyyyyWithSpaces
    }
    private func updateDictionnaryFieldsUpdated(updated: Bool, forKey: String) {
        fieldsUpdated.updateValue(updated, forKey: forKey)
    }
// MARK: - functions
    func customDatePicker() {
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.date = Date()
        datePicker?.locale = .current
        datePicker?.preferredDatePickerStyle = .compact
    }
    private func createObserverPet() {
        createObserverPetTypeSegmentedCtrl()
        createObserverPetName()
        createObserverPetColor()
        createObserverPetParticularSigns()
        createObserverPetGenderSegmentedCtrl()
        createObserverDatePickerBirthDate()
        createObserverPetTatoo()
        createObserverSterilizedSwitch()
        createObserverDatePickerSterilized()
        createObserverVeterinaryPickerView()
        createObserverRacePickerView()
        createObserverWeaningSwitch()
        createObserverDatePickerWeaning()
        createObserverDatePickerDeathDate()
        createObserverPetURLBreederField()
        createObserverPedigreeSwitch()
        createObserverPedigreeNumber()
        createObserverPetMotherNameField()
        createObserverPetFatherNameField()
    }
    private func createDelegatePet() {
        petNameField.delegate = self
        petColorField.delegate = self
        petParticularSignsField.delegate = self
        petBirthDateField.delegate = self
        petTatooField.delegate = self
        petSterilizedDateField.delegate = self
        petVeterinaryField.delegate = self
        petRaceField.delegate = self
        petWeaningDateField.delegate = self
        petDeathDateField.delegate = self
        petBreederView.delegate = self
        petURLBreederField.delegate = self
        petPedigreeNumberField.delegate = self
        petMotherNameField.delegate = self
        petFatherNameField.delegate = self
    }
    private func initiateObserverPet() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(navigationBarPetToTrue),
                                               name: .navigationBarPetToTrue, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(isPetToUpdate),
                                               name: .petIsToUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(isPetDeleted),
                                               name: .petHasBeenDeleted, object: nil)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                              action: #selector(tapGestuireRecognizer(gesture:))))
    }
    private func initiateButtonSwitchViewPet() {
        toggleSavePetButton(shown: false)
        if case .create = typeOfCall {
            savePetButton.title = addButtonTitle
            self.title = newPetTitle
            suppressPetButton.isHidden = true
            vaccinesButton.isHidden = true
            consultationsButton.isHidden = true
            petSterilizedSwitch.isOn = false
            petSterilizedDateField.isEnabled = false
            petWeaningSwitch.isOn = false
            petWeaningDateField.isEnabled = false
            petPedigreeNumberField.isEnabled = false
            petPedigreeNumberField.text =  ""
            petMotherNameField.isEnabled = false
            petMotherNameField.text = ""
            petFatherNameField.isEnabled = false
            petFatherNameField.text = ""
            petCallPhoneField.isHidden = true
        } else {
            savePetButton.title = OKButtonTitle
            self.title = updatePetTitle
        }
        if petBreederView.text.isEmpty {
            petBreederView.text = "Eleveur"
            petBreederView.textColor = UIColor.lightGray
            petBreederView.font = UIFont(name: "raleway", size: 17.0)
            petBreederView.returnKeyType = .done
            petBreederView.delegate = self
        }
    }
    private func initiatePetView() {
        initiatePictureView()
        initiateIdentityFields()
        initiateSterilizedFields(switchStatus: petItem!.petSterilized)
        initiateVeterinaryFields()
        initiateWeaningFields(switchStatus: petItem!.petWeaning)
        initiateBreederFields()
        initiatePedigreeFields(switchStatus: petItem!.petPedigree)
        initiateVaccineButton()
    }
    private func initiatePictureView() {
        guard let imageData = petItem!.petPicture else {
            return
        }
        petPicture.image = UIImage(data: imageData)
    }
    private func initiateIdentityFields() {
        petObjectId = petItem?.objectID
        dateFormatter.locale = localeLanguage
        petTypeSegmentedControl.selectedSegmentIndex = Int(petItem?.petType ?? 0)
        petNameField.text = petItem?.petName
        petGenderSegmentedControl.selectedSegmentIndex = Int(petItem?.petGender ?? 0)
        dateFormatter.dateFormat = dateFormatddMMMMyyyyWithSpaces
        if petItem?.petBirthDate != nil {
            petBirthDateField.text = dateFormatter.string(from: (petItem?.petBirthDate)!)
        }
        petRaceField.text = petItem?.petRace
        petColorField.text = petItem?.petColor
        petParticularSignsField.text = petItem?.petParticularSigns
        petTatooField.text = petItem?.petTatoo
        if petItem?.petDeathDate != nil {
            petDeathDateField.text = dateFormatter.string(from: (petItem?.petDeathDate)!)
        }
    }
    private func initiateSterilizedFields(switchStatus: Bool) {
        petSterilizedSwitch.isOn = switchStatus
        petSterilizedDateField.isEnabled = switchStatus
        if petSterilizedSwitch.isOn {
            dateFormatter.dateFormat = dateFormatddMMMMyyyyWithSpaces
            petSterilizedDateField.text = dateFormatter.string(from: (petItem?.petSterilizedDate)!)
        }
    }
    private func initiateVeterinaryFields() {
        petCallPhoneField.isHidden = true
        guard petItem!.petVeterinary != nil else {
            return
        }
        Model.shared.getVeterinaryFromRecordID(
            veterinaryToSearch: petItem!.petVeterinary!) { (success, veterinaryItem) in
            if success {
                self.selectedVeterinaryObjectID = veterinaryItem?.objectID
                self.selectedVeterinaryRecordID = veterinaryItem?.veterinaryRecordID
                self.petVeterinaryField.text = veterinaryItem?.veterinaryName!
                if !veterinaryItem!.veterinaryPhone!.isEmpty {
                    if self.currentPhoneStatus == .phoneUsable {
                        self.petCallPhoneField.isHidden = false
                    }
                }
            }
        }
    }
    private func initiateWeaningFields(switchStatus: Bool) {
        petWeaningSwitch.isOn = switchStatus
        petWeaningDateField.isEnabled = switchStatus
        if petWeaningSwitch.isOn {
            dateFormatter.dateFormat = dateFormatddMMMMyyyyWithSpaces
            petWeaningDateField.text = dateFormatter.string(from: (petItem?.petWeaningDate)!)
        }
    }
    private func initiateBreederFields() {
        petBreederView.text = petItem?.petBreeder
        petURLBreederField.text = petItem?.petURLBreeder
    }
    private func initiatePedigreeFields(switchStatus: Bool) {
        petPedigreeSwitch.isOn = switchStatus
        petPedigreeNumberField.isEnabled = switchStatus
        petMotherNameField.isEnabled = switchStatus
        petFatherNameField.isEnabled = switchStatus
        petPedigreeNumberField.text = petItem?.petPedigreeNumber
        petMotherNameField.text = petItem?.petMotherName
        petFatherNameField.text = petItem?.petFatherName
    }
    private func initiateVaccineButton() {
        guard let petType =
                petTypeSegmentedControl.titleForSegment(at: petTypeSegmentedControl.selectedSegmentIndex) else {
            return
        }
        if petType == "Rongeur" {
            vaccinesButton.isHidden = true
        }
    }
    private func getRowRaceFromKey(raceToSearch: String) -> Int {
        var rowRace: Int = 0
        switch petTypeSegmentedControl.selectedSegmentIndex {
        case 0:
            rowRace = searchRow(races: catRaces)
            return rowRace
        case 1:
            rowRace = searchRow(races: dogRaces)
            return rowRace
        case 2:
            rowRace = searchRow(races: rabbitRaces)
            return rowRace
        case 3:
            rowRace = searchRow(races: rodentRaces)
            return rowRace
        default:
            return -1
        }
    }
    private func searchRow(races: [String]) -> Int {
        for indice in 0...races.count-1
        where races[indice] == petRaceField.text! {
            return indice
        }
        return -1
    }
    private func checkPetComplete() {
        toggleSavePetButton(shown: false)
        guard let petName = petNameField.text else {
            return
        }
        guard !petName.isEmpty else {
            return
        }
        guard let petBirthDate = petBirthDateField.text else {
            return
        }
        guard !petBirthDate.isEmpty else {
            return
        }
        guard (petPicture.image?.pngData()) != nil else {
            return
        }
        guard checkSterilizedDate() == true else {
            return
        }
        guard checkWeaningDate() == true else {
            return
        }
        toggleSavePetButton(shown: true)
    }
    private func checkSterilizedDate() -> Bool {
        guard petSterilizedSwitch.isOn else {
            return true
        }
        guard let dateSterilized = petSterilizedDateField.text else {
            return false
        }
        guard !dateSterilized.isEmpty else {
            return false
        }
        return true
    }
    private func checkWeaningDate() -> Bool {
        guard petWeaningSwitch.isOn else {
            return true
        }
        guard let dateWeaning = petWeaningDateField.text else {
            return false
        }
        guard !dateWeaning.isEmpty else {
            return false
        }
        return true
    }
    private func toggleSavePetButton(shown: Bool) {
        switch shown {
        case true:
            savePetButton.isEnabled = true
        case false:
            savePetButton.isEnabled = false
        }
        savePetButton.isEnabled = shown
        savePetButton.isAccessibilityElement = shown
    }
}
extension PetViewController {
    private func createObserverPetName() {
        petNameField?.addTarget(self,
                                action: #selector(PetViewController.petNameFieldDidEnd(_:)),
                                for: .editingDidEnd)
    }
     private func createObserverPetColor() {
         petColorField?.addTarget(self,
                                 action: #selector(PetViewController.petColorFieldDidEnd(_:)),
                                 for: .editingDidEnd)
    }
    private func createObserverPetParticularSigns() {
        petParticularSignsField?.addTarget(self,
                                           action: #selector(PetViewController.petParticularSignsFieldDidEnd(_:)),
                                           for: .editingDidEnd)
    }
    private func createObserverPetTatoo() {
        petTatooField?.addTarget(self,
                                action: #selector(PetViewController.petTatooFieldDidEnd(_:)),
                                for: .editingDidEnd)
    }
    private func createObserverDatePickerBirthDate() {
        datePickerBirthDate = UIDatePicker()
        datePickerBirthDate?.datePickerMode = .date
        if #available(iOS 14.0, *) {
            datePickerBirthDate?.preferredDatePickerStyle = .inline
        }
        datePickerBirthDate?.locale = localeLanguage
        datePickerBirthDate?.addTarget(self,
                                       action: #selector(PetViewController.birthDateValueChanged(datePicker:)),
                                       for: .valueChanged)
        petBirthDateField.inputView = datePickerBirthDate
    }
    private func createObserverSterilizedSwitch() {
        petSterilizedSwitch?.addTarget(self,
                                action: #selector(PetViewController.petSterilizedSwitchDidChange(_:)),
                                for: .touchUpInside )
    }
    private func createObserverDatePickerSterilized() {
        datePickerSterilizedDate = UIDatePicker()
        datePickerSterilizedDate?.datePickerMode = .date
        if #available(iOS 14.0, *) {
            datePickerSterilizedDate?.preferredDatePickerStyle = .inline
        }
        datePickerSterilizedDate?.locale = localeLanguage
        datePickerSterilizedDate?.addTarget(self,
                                       action: #selector(PetViewController.dateChangedSterilized(datePicker:)),
                                       for: .valueChanged )
        petSterilizedDateField.inputView = datePickerSterilizedDate
        petSterilizedDateField?.addTarget(self,
                                action: #selector(PetViewController.dateChangedSterilizedField(_:)),
                                for: .editingDidEnd)
    }
    private func createObserverWeaningSwitch() {
        petWeaningSwitch?.addTarget(self,
                                action: #selector(PetViewController.petWeaningSwitchDidChange(_:)),
                                for: .touchUpInside)
    }
    private func createObserverDatePickerWeaning() {
        datePickerWeaningDate = UIDatePicker()
        datePickerWeaningDate?.datePickerMode = .date
        if #available(iOS 14.0, *) {
            datePickerWeaningDate?.preferredDatePickerStyle = .inline
        }
        datePickerWeaningDate?.locale = localeLanguage
        datePickerWeaningDate?.addTarget(self,
                                       action: #selector(PetViewController.dateChangedWeaning(datePicker:)),
                                       for: .valueChanged)
        petWeaningDateField.inputView = datePickerWeaningDate
        petWeaningDateField?.addTarget(self,
                                action: #selector(PetViewController.dateChangedWeaningField(_:)),
                                for: .editingDidEnd)
    }
    private func createObserverDatePickerDeathDate() {
        datePickerDeathDate = UIDatePicker()
        datePickerDeathDate?.datePickerMode = .date
        if #available(iOS 14.0, *) {
            datePickerDeathDate?.preferredDatePickerStyle = .inline
        }
        datePickerDeathDate?.locale = localeLanguage
        datePickerDeathDate?.addTarget(self,
                                       action: #selector(PetViewController.dateChangedDeathDate(datePicker:)),
                                       for: .valueChanged)
        petDeathDateField.inputView = datePickerDeathDate
        petDeathDateField?.addTarget(self,
                                action: #selector(PetViewController.dateChangedDeathField(_:)),
                                for: .editingDidEnd)
    }
    private func createObserverRacePickerView() {
        pickerViewRace.delegate = self
        petRaceField?.addTarget(self,
                                action: #selector(PetViewController.petRaceFieldDidEnd(_:)),
                                for: .editingDidEnd)
        petRaceField.inputView = pickerViewRace
    }
    private func createObserverVeterinaryPickerView() {
        pickerViewVeterinary.delegate = self
        petVeterinaryField?.addTarget(self,
                                action: #selector(PetViewController.petVeterinaryFieldDidEnd(_:)),
                                for: .editingDidEnd)
        petVeterinaryField.inputView = pickerViewVeterinary
    }
    private func createObserverPetTypeSegmentedCtrl() {
        petTypeSegmentedControl?.addTarget(self,
                                       action: #selector(
                                       PetViewController.textChangedPetTypeSegmentedCtrl(typeSegmentedCtrl:)),
                                       for: .valueChanged)
    }
    private func createObserverPetGenderSegmentedCtrl() {
        petGenderSegmentedControl?.addTarget(self,
                                       action: #selector(
                                       PetViewController.textChangedPetGenderSegmentedCtrl(genderSegmentedCtrl:)),
                                       for: .valueChanged)
    }
    private func createObserverPetURLBreederField() {
        petURLBreederField?.addTarget(self,
                                action: #selector(PetViewController.petURLBreederFieldDidEnd(_:)),
                                for: .editingDidEnd)
    }
    private func createObserverPedigreeSwitch() {
        petPedigreeSwitch?.addTarget(self,
                                action: #selector(PetViewController.petPedigreeSwitchDidChange(_:)),
                                for: .touchUpInside)
    }
    private func createObserverPedigreeNumber() {
        petPedigreeNumberField?.addTarget(self,
                                action: #selector(PetViewController.petPedigreeNumberFieldDidEnd(_:)),
                                for: .editingDidEnd)
    }
    private func createObserverPetMotherNameField() {
        petMotherNameField?.addTarget(self,
                                action: #selector(PetViewController.petMotherNameFieldDidEnd(_:)),
                                for: .editingDidEnd)
    }
    private func createObserverPetFatherNameField() {
        petFatherNameField?.addTarget(self,
                                action: #selector(PetViewController.petFatherNameFieldDidEnd(_:)),
                                for: .editingDidEnd)
    }
}
extension PetViewController {
    private func createOrUpdatePet() {
        if case .update = self.typeOfCall {
            let petId = petItem!.objectID
            let petToSave = Model.shared.getObjectByIdPet(objectId: petId)
            updatePetStorage(petToSave: petToSave!)
        } else {
            let petToSave = PetsItem(context: AppDelegate.viewContext)
            petToSave.petRecordID = UUID().uuidString
            updatePetStorage(petToSave: petToSave)
        }
        navigationController?.popViewController(animated: true)
    }
    private func updatePetStorage(petToSave: PetsItem) {
        petToSave.petName = String(petNameField.text ?? "")
        if petImageSelected != nil {
            let imageData = petPicture.image?.pngData()
            petToSave.petPicture = imageData
        }
        petToSave.petType = Int16(petTypeSegmentedControl.selectedSegmentIndex)
        petToSave.petGender = Int16(petGenderSegmentedControl.selectedSegmentIndex)
        if !petBirthDateField.text!.isEmpty {
            petToSave.petBirthDate = dateFormatter.date(from: petBirthDateField.text ?? "")
        }
        petToSave.petTatoo = String(petTatooField.text ?? "")
        petToSave.petSterilized = petSterilizedSwitch.isOn
        if !petSterilizedDateField.text!.isEmpty {
            petToSave.petSterilizedDate = dateFormatter.date(from: petSterilizedDateField.text ?? "")
        } else {
            petToSave.petSterilizedDate = nil
        }
        petToSave.petVeterinary = selectedVeterinaryRecordID
        petToSave.petRace = String(petRaceField.text ?? "")
        petToSave.petWeaning = petWeaningSwitch.isOn
        if !petWeaningDateField.text!.isEmpty {
            petToSave.petWeaningDate = dateFormatter.date(from: petWeaningDateField.text ?? "")
        } else {
            petToSave.petWeaningDate = nil
        }
        if !petDeathDateField.text!.isEmpty {
            petToSave.petDeathDate = dateFormatter.date(from: petDeathDateField.text ?? "")
        } else {
            petToSave.petDeathDate = nil
        }
        petToSave.petColor = String(petColorField.text ?? "")
        if petBreederView.text != "Eleveur" {
            petToSave.petBreeder = String(petBreederView.text ?? "")
        } else {
            petToSave.petBreeder = ""
        }
        petToSave.petURLBreeder = String(petURLBreederField.text ?? "")
        petToSave.petParticularSigns = String(petParticularSignsField.text ?? "")
        petToSave.petPedigree = petPedigreeSwitch.isOn
        petToSave.petPedigreeNumber = String(petPedigreeNumberField.text ?? "")
        petToSave.petMotherName = String(petMotherNameField.text ?? "")
        petToSave.petFatherName = String(petFatherNameField.text ?? "")
//        toDoStorageManager.save()
        try? AppDelegate.viewContext.save()
    }
    private func getVaccines() {
        navigationController?.navigationBar.isUserInteractionEnabled = false
        guard let destVC = self.storyboard?.instantiateViewController(withIdentifier: "ListVaccines")
            as? VaccinesListViewController else {
                return
        }
        destVC.petItem = petItem
        self.show(destVC, sender: self)
    }
    private func getConsultations() {
        navigationController?.navigationBar.isUserInteractionEnabled = false
        guard let destVC = self.storyboard?.instantiateViewController(withIdentifier: "ListConsultations")
            as? ConsultationsListViewController else {
                return
        }
        destVC.petItem = petItem
        self.show(destVC, sender: self)
    }
    private func getSuppressedPet() {
        navigationController?.navigationBar.isUserInteractionEnabled = false
        guard let destVC = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmPetSuppress")
            as? ConfirmPetSuppressViewController else {
                return
        }
        destVC.petItem = petItem
        self.addChild(destVC)
        destVC.view.frame = self.view.frame
        self.view.addSubview(destVC.view)
        destVC.didMove(toParent: self)
    }
    private func callVeterinary() {
        Model.shared.getVeterinaryFromRecordID(
            veterinaryToSearch: selectedVeterinaryRecordID!) { (success, veterinaryItem) in
            if success {
                if !veterinaryItem!.veterinaryPhone!.isEmpty {
                    guard let phoneNumber = veterinaryItem!.veterinaryPhone else {
                        return
                    }
                    if let url = URL(string: "telprompt://\(phoneNumber)") {
                        let application = UIApplication.shared
                        guard application.canOpenURL(url) else {
                            return
                        }
                        application.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
        }
    }
    private func checkUpdatePetDone() {
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
        destVC.typeOfCaller = TypeOfCaller.pet
        destVC.view.frame = self.view.frame
        self.view.addSubview(destVC.view)
        destVC.didMove(toParent: self)
    }
}
// MARK: - extension for UIPickerView
extension PetViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pickerViewVeterinary {
            veterinariesList = VeterinariesItem.fetchAll()
            return veterinariesList.count
        } else {
            switch petTypeSegmentedControl.selectedSegmentIndex {
            case 0:
                return catRaces.count
            case 1:
                return dogRaces.count
            case 2:
                return rabbitRaces.count
            case 3:
                return rodentRaces.count
            default:
                return 0
            }
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pickerViewVeterinary {
            veterinariesList = VeterinariesItem.fetchAll()
            return veterinariesList[row].veterinaryName
        } else {
            switch petTypeSegmentedControl.selectedSegmentIndex {
            case 0:
                return catRaces[row]
            case 1:
                return dogRaces[row]
            case 2:
                return rabbitRaces[row]
            case 3:
                return rodentRaces[row]
            default:
                return nil
            }
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pickerViewVeterinary {
            veterinariesList = VeterinariesItem.fetchAll()
            selectedVeterinaryObjectID = veterinariesList[row].objectID
            selectedVeterinaryRecordID = veterinariesList[row].veterinaryRecordID
            petVeterinaryField.text =  veterinariesList[row].veterinaryName
        } else {
            switch petTypeSegmentedControl.selectedSegmentIndex {
            case 0:
                selectedRace = catRaces[row]
            case 1:
                selectedRace = dogRaces[row]
            case 2:
                selectedRace = rabbitRaces[row]
            case 3:
                selectedRace = rodentRaces[row]
            default:
                selectedRace = ""
            }
            petRaceField.text = selectedRace
        }
    }
}
// MARK: - UITextFieldDelegate
extension PetViewController: UITextFieldDelegate {
     func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        typeFieldOrView = "UITextField"
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
extension PetViewController: UITextViewDelegate {
    internal func textViewDidBeginEditing(_ textView: UITextView) {
        typeFieldOrView = "UITextView"
    }
    internal func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        typeFieldOrView = "UITextView"
        lastOffset = self.scrollView.contentOffset
        petBreederView.textColor =  #colorLiteral(red: 1, green: 0.2730214596, blue: 0.2258683443, alpha: 1)
        return true
    }
    internal func textViewDidEndEditing(_ textView: UITextView) {
        if petBreederView.text != petItem?.petBreeder {
            updateDictionnaryFieldsUpdated(updated: true, forKey: "petBreederUpdated")
        } else {
            updateDictionnaryFieldsUpdated(updated: false, forKey: "petBreederUpdated")
        }
        if #available(iOS 13.0, *) {
            petBreederView.textColor = UIColor.label
        } else {
            petBreederView.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        petBreederView.resignFirstResponder()
    }
}
// MARK: - Keyboard Handling
private extension PetViewController {
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
                        self.scrollView.frame.size.height
                        - (activeField?.frame.origin.y)!
                        - (activeField?.frame.size.height)!
                } else {
                    distanceToBottom =
                        self.scrollView.frame.size.height
                        - (petBreederView.frame.origin.y)
                        - (petBreederView.frame.size.height)
                }
                if distanceToBottom > keyboardHeight {
                    return
                }
                let collapseSpace = (keyboardHeight - distanceToBottom + 10)
                UIView.animate(withDuration: 0.3, animations: {
                    self.scrollView.contentOffset = CGPoint(x: self.lastOffset.x, y: collapseSpace)
                })
            }
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
extension PetViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        guard let image = image else {
            return
        }
        self.petPicture.image = image
        petImageSelected = image
        updateDictionnaryFieldsUpdated(updated: true, forKey: "petPictureUpdated")
    }
}
