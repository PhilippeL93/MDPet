//
//  PetViewController.swift
//  MDPet
//
//  Created by Philippe on 18/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

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
    private var selectedVeterinaryKey: String = ""
    private var typeFieldOrView: String = ""
    private var selectedVeterinaryName = ""

    var typeOfCall: TypeOfCall?
    var petItem: PetItem?
    private var veterinariesItems: [VeterinaryItem] = []
    private var petKey: String = ""
    private var databaseRef = Database.database().reference(withPath: petsItem)
    private var imageRef = Storage.storage().reference().child(petsInages)
    private var pathPet: String = ""
    private var oneFieldHasBeenUpdated = false

    var imagePicker: ImagePicker!

    private var fieldsUpdated: [String: Bool] = [:] {
        didSet {
            oneFieldHasBeenUpdated = false
            for (_, hasBeenUpdated) in fieldsUpdated
                where hasBeenUpdated == true {
                    oneFieldHasBeenUpdated = true
            }
            if case .create = typeOfCall {
                toggleSavePetButton(shown: false)
                checkPetComplete()
            } else {
                toggleSavePetButton(shown: oneFieldHasBeenUpdated)
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
        pathPet = UserUid.uid
        databaseRef = Database.database().reference(withPath: "\(pathPet)")
        createObserverPet()
        createDelegatePet()
        initiateObserverPet()
        GetFirebaseVeterinaries.shared.observeVeterinaries { (success, veterinariesItems) in
            if success {
                self.veterinariesItems = veterinariesItems
                if case .update = self.typeOfCall {
                    self.initiatePetView()
                }
                self.initiateButtonSwitchViewPet()
                self.imagePicker = ImagePicker(presentationController: self, delegate: self)
            } else {
                print("erreur")
            }
        }
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
            if petTypeSegmentedControl.selectedSegmentIndex != petItem?.petType {
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
            if petGenderSegmentedControl.selectedSegmentIndex != petItem?.petGender {
                updateDictionnaryFieldsUpdated(updated: true, forKey: "petGenderUpdated")
            } else {
                updateDictionnaryFieldsUpdated(updated: false, forKey: "petGenderUpdated")
            }
            self.pickerViewGender.reloadAllComponents()
        }
        @objc func birthDateValueChanged(datePicker: UIDatePicker) {
            petBirthDateField.text = dateFormatter.string(from: datePicker.date)
            if petBirthDateField.text != petItem?.petBirthDate {
                updateDictionnaryFieldsUpdated(updated: true, forKey: "petBirthDateUpdated")
            } else {
                updateDictionnaryFieldsUpdated(updated: false, forKey: "petBirthDateUpdated")
            }
            formatDate()
            petBirthDateField.text = dateFormatter.string(from: datePicker.date)
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
                petSterilizedDateField.text = petItem?.petSterilizedDate
            } else {
                petSterilizedDateField.isEnabled = false
                petSterilizedDateField.text =  ""
            }
            if petSterilizedSwitch.isOn != petItem?.petSterilized {
                updateDictionnaryFieldsUpdated(updated: true, forKey: "petSterilizedSwitchUpdated")
            } else {
                updateDictionnaryFieldsUpdated(updated: false, forKey: "petSterilizedSwitchUpdated")
            }
        }
        @objc func dateChangedSterilized(datePicker: UIDatePicker) {
            petSterilizedDateField.text = dateFormatter.string(from: datePicker.date)
            if petSterilizedDateField.text != petItem?.petSterilizedDate {
                updateDictionnaryFieldsUpdated(updated: true, forKey: "petSterilizedDateUpdated")
            } else {
                updateDictionnaryFieldsUpdated(updated: false, forKey: "petSterilizedDateUpdated")
            }
            formatDate()
        }
        @objc func petVeterinaryFieldDidEnd(_ textField: UITextField) {
            selectedVeterinaryName = ""
            if case .update = typeOfCall {
                if !petItem!.petVeterinary.isEmpty {
                    GetFirebaseVeterinaries.shared.getVeterinaryFromKey(
                    veterinaryToSearch: petItem!.petVeterinary) { (success, veterinariesItems, _) in
                        if success {
                            self.selectedVeterinaryName = veterinariesItems.veterinaryName
                        }
                    }
                }
            }
            if petVeterinaryField.text != selectedVeterinaryName {
                updateDictionnaryFieldsUpdated(updated: true, forKey: "petVeterinaryUpdated")
            } else {
                updateDictionnaryFieldsUpdated(updated: false, forKey: "petVeterinaryUpdated")
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
                petWeaningDateField.text = petItem?.petWeaningDate
            } else {
                petWeaningDateField.isEnabled = false
                petWeaningDateField.text =  ""
            }
            if petWeaningSwitch.isOn != petItem?.petWeaning {
                updateDictionnaryFieldsUpdated(updated: true, forKey: "petWeaningSwitchUpdated")
            } else {
                updateDictionnaryFieldsUpdated(updated: false, forKey: "petWeaningSwitchUpdated")
            }
        }
        @objc func dateChangedWeaning(datePicker: UIDatePicker) {
            petWeaningDateField.text = dateFormatter.string(from: datePicker.date)
            if petWeaningDateField.text != petItem?.petWeaningDate {
                updateDictionnaryFieldsUpdated(updated: true, forKey: "petWeaningDateUpdated")
            } else {
                updateDictionnaryFieldsUpdated(updated: false, forKey: "petWeaningDateUpdated")
            }
            formatDate()
        }
        @objc func dateChangedDeathDate(datePicker: UIDatePicker) {
            petDeathDateField.text = dateFormatter.string(from: datePicker.date)
            if petDeathDateField.text != petItem?.petDeathDate {
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
//        initiateSterilizedFields()
        initiateSterilizedFields(switchStatus: petItem!.petSterilized)
        initiateVeterinaryFields()
        initiateWeaningFields(switchStatus: petItem!.petWeaning)
        initiateBreederFields()
        initiatePedigreeFields(switchStatus: petItem!.petPedigree)
        initiateVaccineButton()

    }
    private func initiatePictureView() {
        petPicture.image = nil
        if let URLPicture = petItem?.petURLPicture {
            GetFirebasePicture.shared.getPicture(URLPicture: URLPicture) { (success, picture) in
                if success, let picture = picture {
                    self.petPicture.image = picture
                }
            }
        }
    }
    private func initiateIdentityFields() {
        petKey = petItem?.key ?? ""
        petTypeSegmentedControl.selectedSegmentIndex = petItem?.petType ?? 0
        petNameField.text = petItem?.petName
        petGenderSegmentedControl.selectedSegmentIndex = petItem?.petGender ?? 0
        petBirthDateField.text = petItem?.petBirthDate
        petRaceField.text = petItem?.petRace
        petColorField.text = petItem?.petColor
        petParticularSignsField.text = petItem?.petParticularSigns
        petTatooField.text = petItem?.petTatoo
        petDeathDateField.text = petItem?.petDeathDate
    }
    private func initiateSterilizedFields(switchStatus: Bool) {
        petSterilizedDateField.text = petItem?.petSterilizedDate
        petSterilizedSwitch.isOn = switchStatus
        petSterilizedDateField.isEnabled = switchStatus

    }
    private func initiateVeterinaryFields() {
        petCallPhoneField.isHidden = true
        guard !petItem!.petVeterinary.isEmpty else {
            return
        }
        GetFirebaseVeterinaries.shared.getVeterinaryFromKey(
        veterinaryToSearch: petItem!.petVeterinary) { (success, veterinariesItems, _) in
            if success {
                self.petVeterinaryField.text = veterinariesItems.veterinaryName
                if !veterinariesItems.veterinaryPhone.isEmpty {
                    if self.currentPhoneStatus == .phoneUsable {
                        self.petCallPhoneField.isHidden = false
                    }
                }
            }
        }
        selectedVeterinaryKey = petItem?.petVeterinary ?? ""
    }
    private func initiateWeaningFields(switchStatus: Bool) {
        petWeaningSwitch.isOn = switchStatus
        petWeaningDateField.isEnabled = switchStatus
        petWeaningDateField.text = petItem?.petWeaningDate
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
        toggleSavePetButton(shown: true)
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
        datePickerBirthDate?.locale = localeLanguage
        datePickerBirthDate?.addTarget(self,
                                       action: #selector(PetViewController.birthDateValueChanged(datePicker:)),
                                       for: .valueChanged)
        petBirthDateField.inputView = datePickerBirthDate
    }
    private func createObserverSterilizedSwitch() {
        petSterilizedSwitch?.addTarget(self,
                                action: #selector(PetViewController.petSterilizedSwitchDidChange(_:)),
                                for: .touchUpInside)
    }
    private func createObserverDatePickerSterilized() {
        datePickerSterilizedDate = UIDatePicker()
        datePickerSterilizedDate?.datePickerMode = .date
        datePickerSterilizedDate?.locale = localeLanguage
        datePickerSterilizedDate?.addTarget(self,
                                       action: #selector(PetViewController.dateChangedSterilized(datePicker:)),
                                       for: .valueChanged)
        petSterilizedDateField.inputView = datePickerSterilizedDate
    }
    private func createObserverWeaningSwitch() {
        petWeaningSwitch?.addTarget(self,
                                action: #selector(PetViewController.petWeaningSwitchDidChange(_:)),
                                for: .touchUpInside)
    }
    private func createObserverDatePickerWeaning() {
        datePickerWeaningDate = UIDatePicker()
        datePickerWeaningDate?.datePickerMode = .date
        datePickerWeaningDate?.locale = localeLanguage
        datePickerWeaningDate?.addTarget(self,
                                       action: #selector(PetViewController.dateChangedWeaning(datePicker:)),
                                       for: .valueChanged)
        petWeaningDateField.inputView = datePickerWeaningDate
    }
    private func createObserverDatePickerDeathDate() {
        datePickerDeathDate = UIDatePicker()
        datePickerDeathDate?.datePickerMode = .date
        datePickerDeathDate?.locale = localeLanguage
        datePickerDeathDate?.addTarget(self,
                                       action: #selector(PetViewController.dateChangedDeathDate(datePicker:)),
                                       for: .valueChanged)
        petDeathDateField.inputView = datePickerDeathDate
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
        databaseRef = Database.database().reference(withPath: "\(pathPet)")
//        guard let petKey = petItem?.key else {
//            return
//        }
        var storageRef = imageRef.child("\(String(describing: petKey)).png")
        var uniqueUUID = petKey

        if case .create = typeOfCall {
            uniqueUUID = UUID().uuidString
            storageRef = imageRef.child("\(String(describing: uniqueUUID)).png")
        }

        if let uploadData = self.petPicture.image?.pngData() {
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
//                  guard let url = url else {
//                      return }
                    let petURLPicture = (url?.absoluteString) ?? ""
                    self.updatePetStorage(petURLPicture: petURLPicture, uniqueUUID: uniqueUUID)
                })
            })
        } else {
            updatePetStorage(petURLPicture: "", uniqueUUID: uniqueUUID)
        }
    }
    private func updatePetStorage(petURLPicture: String, uniqueUUID: String) {
        petItem = PetItem(
            name: "", key: "",
            URLPicture: "", type: 0,
            gender: 0, birthDate: "",
            tatoo: "", sterilized: false,
            sterilizedDate: "", veterinary: "",
            race: "", weaning: false,
            weaningDate: "", deathDate: "",
            color: "", breeder: "",
            URLBreeder: "", particularSigns: "",
            pedigree: false, pedigreeNumber: "",
            motherName: "", fatherName: ""
        )
        petItem?.petName = String(petNameField.text ?? "")
        petItem?.petURLPicture = petURLPicture
        petItem?.petType = petTypeSegmentedControl.selectedSegmentIndex
        petItem?.petGender = petGenderSegmentedControl.selectedSegmentIndex
        petItem?.petBirthDate = String(petBirthDateField.text ?? "")
        petItem?.petTatoo = String(petTatooField.text ?? "")
        petItem?.petSterilized = petSterilizedSwitch.isOn
        petItem?.petSterilizedDate = String(petSterilizedDateField.text ?? "")
        petItem?.petVeterinary = String(selectedVeterinaryKey)
        petItem?.petRace = String(petRaceField.text ?? "")
        petItem?.petWeaning = petWeaningSwitch.isOn
        petItem?.petWeaningDate = String(petWeaningDateField.text ?? "")
        petItem?.petDeathDate = String(petDeathDateField.text ?? "")
        petItem?.petColor = String(petColorField.text ?? "")
        petItem?.petBreeder = String(petBreederView.text ?? "")
        petItem?.petURLBreeder = String(petURLBreederField.text ?? "")
        petItem?.petParticularSigns = String(petParticularSignsField.text ?? "")
        petItem?.petPedigree = petPedigreeSwitch.isOn
        petItem?.petPedigreeNumber = String(petPedigreeNumberField.text ?? "")
        petItem?.petMotherName = String(petMotherNameField.text ?? "")
        petItem?.petFatherName = String(petFatherNameField.text ?? "")

        let petItemRef = databaseRef.child(petsItem).child(uniqueUUID)
        petItemRef.setValue(petItem?.toAnyObject())
        if currentReachabilityStatus == .twoG || currentReachabilityStatus == .threeG {
           print("======== connection lente détectée \(currentReachabilityStatus)")
        }
        navigationController?.popViewController(animated: true)
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
        for indice in 0...veterinariesItems.count - 1
            where selectedVeterinaryKey == veterinariesItems[indice].key {
                if let url = URL(string: "telprompt://\(veterinariesItems[indice].veterinaryPhone)") {
                    let application = UIApplication.shared
                    guard application.canOpenURL(url) else {
                        return
                    }
                    application.open(url, options: [:], completionHandler: nil)
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
            return veterinariesItems.count
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
            return veterinariesItems[row].veterinaryName
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
            selectedVeterinaryKey = veterinariesItems[row].key
            petVeterinaryField.text = veterinariesItems[row].veterinaryName
            //            petVeterinaryField.resignFirstResponder()
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
        //            petRaceField.resignFirstResponder()
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
        updateDictionnaryFieldsUpdated(updated: true, forKey: "petPictureUpdated")
    }
}
