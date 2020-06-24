//
//  NewPetViewController.swift
//  MDPet
//
//  Created by Philippe on 18/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit
import Firebase

class NewPetViewController: UIViewController {

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
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var savePetButton: UIBarButtonItem!
    @IBOutlet weak var suppressPetButton: UIButton!

    // MARK: - variables
    private let imagePicker = UIImagePickerController()
    private var pickerViewGender = UIPickerView()
    private var datePickerBirthDate: UIDatePicker?
    private var petSterilized: UISwitch?
    private var datePickerSterilizedDate: UIDatePicker?
    private var petWeaning: UISwitch?
    private var datePickerWeaningDate: UIDatePicker?
    private var datePickerDeathDate: UIDatePicker?
    private var pickerViewVeterinary = UIPickerView()
    private var pickerViewRace = UIPickerView()
    private var activeField: UITextField?
    private var lastOffset: CGPoint!
    private var keyboardHeight: CGFloat!
    private var constraintContentHeight: CGFloat!
    private let localeLanguage = Locale(identifier: "FR-fr")
    private var dateFormatter = DateFormatter()
    private var selectedRace: String = ""
    private var selectedVeterinaryKey: String = ""
    private var typeFieldOrView: String = ""

    var veterinariesItems: [VeterinaryItem] = []
    var typeOfCall: String = ""
    var petItem: PetItem?
    var petKey: String = ""
    var databaseRef = Database.database().reference(withPath: "pets-item")
    var imageRef = Storage.storage().reference().child("pets-images")
//    let usersRef = Database.database().reference(withPath: "online")
    private var pathPet: String = ""

// MARK: - buttons

    @IBAction func addPetPhoto(_ sender: Any) {
        selectImageOrCamera(animated: true)
    }
    @IBAction func savePet(_ sender: Any) {
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
    @IBAction func veterinaryEditingDidBegin(_ sender: Any) {
        if !petVeterinaryField.text!.isEmpty {
            let rowVeterinary = getVeterinaryNameFromKey(veterinaryToSearch: selectedVeterinaryKey)
            pickerViewVeterinary.selectRow(rowVeterinary, inComponent: 0, animated: true)
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
        pathPet = UserUid.uid + "-pets-item"
        databaseRef = Database.database().reference(withPath: "\(pathPet)")
        createObserver()
        createDelegate()
        toggleSavePetButton(shown: false)
        initiateObserver()
        GetFirebaseVeterinaries.shared.observeVeterinaries { (success, veterinariesItems) in
            if success {
                self.veterinariesItems = veterinariesItems
                if self.typeOfCall == "update" {
                    self.initiatePictureView()
                }
            } else {
                print("erreur")
            }
        }
        initiateView()
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .navigationBarPetToTrue, object: nil)
        NotificationCenter.default.removeObserver(self, name: .isToUpdate, object: nil)
        NotificationCenter.default.removeObserver(self, name: .hasBeenDeleted, object: nil)
    }
}
    extension NewPetViewController {
// MARK: - @objc func
    @objc func returnView(gesture: UIGestureRecognizer) {
        guard !typeFieldOrView.isEmpty else {
            return
        }
        if typeFieldOrView == "UITextField" {
            guard activeField != nil else {
                return
            }
            activeField?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            activeField?.resignFirstResponder()
            activeField = nil
        } else {
            petBreederView.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
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
        checkChangeDone()
        petRaceField.text = ""
        self.pickerViewRace.reloadAllComponents()
    }
    @objc func petNameFieldDidChange(_ textField: UITextField) {
        checkChangeDone()
    }
    @objc func textChangedPetGenderSegmentedCtrl(genderSegmentedCtrl: UISegmentedControl) {
        checkChangeDone()
        self.pickerViewGender.reloadAllComponents()
    }
    @objc func dateChangedBirthDate(datePicker: UIDatePicker) {
        petBirthDateField.text = dateFormatter.string(from: datePicker.date)
        checkChangeDone()
            formatDate()
        petBirthDateField.text = dateFormatter.string(from: datePicker.date)
    }
    @objc func petTatooFieldDidChange(_ textField: UITextField) {
        checkChangeDone()
    }
    @objc func petSterilizedSwitchDidChange(_ textField: UISwitch) {
        if petSterilizedSwitch.isOn == true {
            petSterilizedDateField.isEnabled = true
            petSterilizedDateField.text = petItem?.petSterilizedDate
        } else {
            petSterilizedDateField.isEnabled = false
            petSterilizedDateField.text =  ""
        }
        checkChangeDone()
    }
    @objc func dateChangedSterilized(datePicker: UIDatePicker) {
        petSterilizedDateField.text = dateFormatter.string(from: datePicker.date)
        checkChangeDone()
        formatDate()
    }
    @objc func petVeterinaryFieldDidChange(_ textField: UITextField) {
        checkChangeDone()
    }
    @objc func petRaceFieldDidChange(_ textField: UITextField) {
        checkChangeDone()
    }
    @objc func petColorFieldDidChange(_ textField: UITextField) {
        checkChangeDone()
    }
    @objc func petParticularSignsFieldDidChange(_ textField: UITextField) {
        checkChangeDone()
    }
    @objc func petWeaningSwitchDidChange(_ textField: UISwitch) {
        if petWeaningSwitch.isOn == true {
            petWeaningDateField.isEnabled = true
            petWeaningDateField.text = petItem?.petWeaningDate
        } else {
            petWeaningDateField.isEnabled = false
            petWeaningDateField.text =  ""
        }
        checkChangeDone()
    }
    @objc func dateChangedWeaning(datePicker: UIDatePicker) {
        petWeaningDateField.text = dateFormatter.string(from: datePicker.date)
        checkChangeDone()
        formatDate()
    }
    @objc func dateChangedDeathDate(datePicker: UIDatePicker) {
        petDeathDateField.text = dateFormatter.string(from: datePicker.date)
        checkChangeDone()
        formatDate()
    }
    private func formatDate() {
        dateFormatter.locale = localeLanguage
        dateFormatter.dateFormat = "dd MMMM yyyy"
    }

// MARK: - functions
    private func createObserver() {
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
    }
    private func createDelegate() {
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
    }
    private func initiateObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(navigationBarPetToTrue),
                                               name: .navigationBarPetToTrue, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(isPetToUpdate),
                                               name: .isToUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(isPetDeleted),
                                               name: .hasBeenDeleted, object: nil)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                              action: #selector(returnView(gesture:))))
    }
    private func initiateView() {
        if typeOfCall == "create" {
            savePetButton.title = "Ajouter"
            self.title = "Nouvel animal"
            suppressPetButton.isHidden = true
            petSterilizedSwitch.isOn = false
            petSterilizedDateField.isEnabled = false
            petWeaningSwitch.isOn = false
            petWeaningDateField.isEnabled = false
        } else {
            savePetButton.title = "OK"
            self.title = "Modification animal"
        }
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
        initiateFieldsView()
    }
    private func initiateFieldsView() {
        petKey = petItem?.key ?? ""
        petTypeSegmentedControl.selectedSegmentIndex = petItem?.petType ?? 0
        petNameField.text = petItem?.petName
        petGenderSegmentedControl.selectedSegmentIndex = petItem?.petGender ?? 0
        petBirthDateField.text = petItem?.petBirthDate
        petTatooField.text = petItem?.petTatoo
        petSterilizedDateField.text = petItem?.petSterilizedDate
        if petItem?.petSterilized == true {
            petSterilizedSwitch.isOn = true
            petSterilizedDateField.isEnabled = true
        } else {
            petSterilizedSwitch.isOn = false
            petSterilizedDateField.isEnabled = false
        }
        let rowVeterinary = getVeterinaryNameFromKey(veterinaryToSearch: petItem!.petVeterinary)
        if rowVeterinary != -1 {
            petVeterinaryField.text = veterinariesItems[rowVeterinary].veterinaryName
        }
        selectedVeterinaryKey = petItem?.petVeterinary ?? ""
        petRaceField.text = petItem?.petRace
        if petItem?.petWeaning == true {
            petWeaningSwitch.isOn = true
            petWeaningDateField.isEnabled = true
        } else {
            petWeaningSwitch.isOn = false
            petWeaningDateField.isEnabled = false
        }
        petWeaningDateField.text = petItem?.petWeaningDate
        petDeathDateField.text = petItem?.petDeathDate
        petColorField.text = petItem?.petColor
        petBreederView.text = petItem?.petBreeder
        petParticularSignsField.text = petItem?.petParticularSigns
    }
    private func getVeterinaryNameFromKey(veterinaryToSearch: String) -> Int {
        guard veterinariesItems.count != 0 else {
            return -1
        }
        for indice in 0...veterinariesItems.count-1
            where veterinariesItems[indice].key == veterinaryToSearch {
                return indice
        }
        return -1
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

extension NewPetViewController {

    private func checkChangeDone() {
        if petTypeSegmentedControl.selectedSegmentIndex != petItem?.petType {
            toggleSavePetButton(shown: true)
            return
        }
        if petNameField.text != petItem?.petName {
            toggleSavePetButton(shown: true)
            return
        }
        if petGenderSegmentedControl.selectedSegmentIndex != petItem?.petGender {
            toggleSavePetButton(shown: true)
            return
        }
        if petBirthDateField.text != petItem?.petBirthDate {
            toggleSavePetButton(shown: true)
            return
        }
        if petRaceField.text != petItem?.petRace {
            toggleSavePetButton(shown: true)
            return
        }
        if petColorField.text != petItem?.petColor {
            toggleSavePetButton(shown: true)
            return
        }
        if petParticularSignsField.text != petItem?.petParticularSigns {
            toggleSavePetButton(shown: true)
            return
        }
        if petTatooField.text != petItem?.petTatoo {
            toggleSavePetButton(shown: true)
            return
        }
        if petBreederView.text != petItem?.petBreeder {
            toggleSavePetButton(shown: true)
            return
        }
        var selectedVeterinaryName = ""
        let rowVeterinary = getVeterinaryNameFromKey(veterinaryToSearch: petItem!.petVeterinary)
        if rowVeterinary != -1 {
            selectedVeterinaryName = veterinariesItems[rowVeterinary].veterinaryName
            }
        if petVeterinaryField.text != selectedVeterinaryName {
            toggleSavePetButton(shown: true)
            return
        }
        if petSterilizedSwitch.isOn != petItem?.petSterilized {
            toggleSavePetButton(shown: true)
            return
        }
        if petSterilizedDateField.text != petItem?.petSterilizedDate {
            toggleSavePetButton(shown: true)
            return
        }
        if petWeaningSwitch.isOn != petItem?.petWeaning {
            toggleSavePetButton(shown: true)
            return
        }
        if petWeaningDateField.text != petItem?.petWeaningDate {
            toggleSavePetButton(shown: true)
            return
        }
        if petDeathDateField.text != petItem?.petDeathDate {
            toggleSavePetButton(shown: true)
            return
        } else {
            toggleSavePetButton(shown: false)
        }
    }

    private func createObserverPetName() {
        petNameField?.addTarget(self,
                                action: #selector(NewPetViewController.petNameFieldDidChange(_:)),
                                for: .editingChanged)
    }
     private func createObserverPetColor() {
         petColorField?.addTarget(self,
                                 action: #selector(NewPetViewController.petColorFieldDidChange(_:)),
                                 for: .editingChanged)
    }
    private func createObserverPetParticularSigns() {
        petParticularSignsField?.addTarget(self,
                                           action: #selector(NewPetViewController.petParticularSignsFieldDidChange(_:)),
                                           for: .editingChanged)
    }
    private func createObserverPetTatoo() {
        petTatooField?.addTarget(self,
                                action: #selector(NewPetViewController.petTatooFieldDidChange(_:)),
                                for: .editingChanged)
    }
    private func createObserverDatePickerBirthDate() {
        datePickerBirthDate = UIDatePicker()
        datePickerBirthDate?.datePickerMode = .date
        datePickerBirthDate?.locale = localeLanguage
        datePickerBirthDate?.addTarget(self,
                                       action: #selector(NewPetViewController.dateChangedBirthDate(datePicker:)),
                                       for: .valueChanged)
        petBirthDateField.inputView = datePickerBirthDate
    }
    private func createObserverSterilizedSwitch() {
        petSterilizedSwitch?.addTarget(self,
                                action: #selector(NewPetViewController.petSterilizedSwitchDidChange(_:)),
                                for: .touchUpInside)
    }
    private func createObserverDatePickerSterilized() {
        datePickerSterilizedDate = UIDatePicker()
        datePickerSterilizedDate?.datePickerMode = .date
        datePickerSterilizedDate?.locale = localeLanguage
        datePickerSterilizedDate?.addTarget(self,
                                       action: #selector(NewPetViewController.dateChangedSterilized(datePicker:)),
                                       for: .valueChanged)
        petSterilizedDateField.inputView = datePickerSterilizedDate
    }
    private func createObserverWeaningSwitch() {
        petWeaningSwitch?.addTarget(self,
                                action: #selector(NewPetViewController.petWeaningSwitchDidChange(_:)),
                                for: .touchUpInside)
    }
    private func createObserverDatePickerWeaning() {
        datePickerWeaningDate = UIDatePicker()
        datePickerWeaningDate?.datePickerMode = .date
        datePickerWeaningDate?.locale = localeLanguage
        datePickerWeaningDate?.addTarget(self,
                                       action: #selector(NewPetViewController.dateChangedWeaning(datePicker:)),
                                       for: .valueChanged)
        petWeaningDateField.inputView = datePickerWeaningDate
    }
    private func createObserverDatePickerDeathDate() {
        datePickerDeathDate = UIDatePicker()
        datePickerDeathDate?.datePickerMode = .date
        datePickerDeathDate?.locale = localeLanguage
        datePickerDeathDate?.addTarget(self,
                                       action: #selector(NewPetViewController.dateChangedDeathDate(datePicker:)),
                                       for: .valueChanged)
        petDeathDateField.inputView = datePickerDeathDate
    }
    private func createObserverRacePickerView() {
        pickerViewRace.delegate = self
        petRaceField?.addTarget(self,
                                action: #selector(NewPetViewController.petRaceFieldDidChange(_:)),
                                for: .editingChanged)
        petRaceField.inputView = pickerViewRace
    }
    private func createObserverVeterinaryPickerView() {
        pickerViewVeterinary.delegate = self
        petVeterinaryField?.addTarget(self,
                                action: #selector(NewPetViewController.petVeterinaryFieldDidChange(_:)),
                                for: .editingChanged )
        petVeterinaryField.inputView = pickerViewVeterinary
    }
    private func createObserverPetTypeSegmentedCtrl() {
        petTypeSegmentedControl?.addTarget(self,
                                       action: #selector(
                                       NewPetViewController.textChangedPetTypeSegmentedCtrl(typeSegmentedCtrl:)),
                                       for: .valueChanged)
    }
    private func createObserverPetGenderSegmentedCtrl() {
        petGenderSegmentedControl?.addTarget(self,
                                       action: #selector(
                                       NewPetViewController.textChangedPetGenderSegmentedCtrl(genderSegmentedCtrl:)),
                                       for: .valueChanged)
    }
    // MARK: - images management
    ///   selectImageOrCamera in order to choose between
    ///    - photo from library of Iphone ==> call function getImage with parameter photo
    ///    - to take a photo with camera ==> call function getImage with parameter camera
    private func selectImageOrCamera(animated: Bool) {
        let alert = UIAlertController(title: "Choix", message: "Que voulez vous faire?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Sélectionner une photo", style: .default, handler: { (_) in
            self.getImage(source: "photo")
        }))
        alert.addAction(UIAlertAction(title: "Prendre une photo", style: .default, handler: { (_)in
            self.getImage(source: "camera")
        }))
        alert.addAction(UIAlertAction(title: "Abandonnner", style: .cancel, handler: { (_)in
        }))
        present(alert, animated: true, completion: {
        })
    }

    ///   getImage in order to call imagePickerController
    ///     - if photo direct imagePickerController with source photoLibrary
    ///     - if camera verifying available on this device
    ///         - if camera available call of imagePickerController with source camera
    ///             - else error noCamera
    private func getImage(source: String) {
        let source = source
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        switch source {
        case "photo":
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.modalPresentationStyle = .fullScreen
        case "camera":
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                imagePicker.cameraCaptureMode = .photo
                imagePicker.modalPresentationStyle = .fullScreen
            } else {
                getErrors(type: .noCamera)
            }
        default:
            break
        }
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true)
    }
    private func createOrUpdatePet() {
        databaseRef = Database.database().reference(withPath: "\(pathPet)")
        var storageRef = imageRef.child("\(String(describing: petItem?.key)).png")
        var uniqueUUID = petKey

        if typeOfCall == "create" {
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
                    guard let url = url else {
                        return }
                    let petURLPicture = url.absoluteString
                    self.updatePetStorage(petURLPicture: petURLPicture, uniqueUUID: uniqueUUID)
                })
            })
        } else {
            updatePetStorage(petURLPicture: "", uniqueUUID: uniqueUUID)
        }
        navigationController?.popViewController(animated: true)
    }
    private func updatePetStorage(petURLPicture: String, uniqueUUID: String) {
        petItem = PetItem(
            name: String(self.petNameField.text ?? ""),
            key: "",
            URLPicture: petURLPicture,
            type: petTypeSegmentedControl.selectedSegmentIndex,
            gender: petGenderSegmentedControl.selectedSegmentIndex,
            birthDate: String(petBirthDateField.text ?? ""),
            tatoo: String(petTatooField.text ?? ""),
            sterilized: petSterilizedSwitch.isOn,
            sterilizedDate: String(petSterilizedDateField.text ?? ""),
            veterinary: String(selectedVeterinaryKey),
            race: String(petRaceField.text ?? ""),
            weaning: petWeaningSwitch.isOn,
            weaningDate: String(petWeaningDateField.text ?? ""),
            deathDate: String(petDeathDateField.text ?? ""),
            color: String(petColorField.text ?? ""),
            breeder: String(petBreederView.text ?? ""),
            particularSigns: String(petParticularSignsField.text ?? ""))
        let petItemRef = databaseRef.child(uniqueUUID)
        petItemRef.setValue(petItem?.toAnyObject())
    }
    private func getSuppressedPet() {
        navigationController?.navigationBar.isUserInteractionEnabled = false
        guard let destVC = self.storyboard?.instantiateViewController(withIdentifier: "confirmPetSuppress")
            as? ConfirmPetSuppressViewController else {
                return
        }
        destVC.petItem = petItem
        self.addChild(destVC)
        destVC.view.frame = self.view.frame
        self.view.addSubview(destVC.view)
        destVC.didMove(toParent: self)
    }
    private func checkUpdatePetDone() {
        if savePetButton.isEnabled == false {
            navigationController?.popViewController(animated: true)
            return
        }
        navigationController?.navigationBar.isUserInteractionEnabled = false
        guard let destVC = self.storyboard?.instantiateViewController(withIdentifier: "confirmUpdate")
            as? ConfirmUpdateViewController else {
                return
        }
        self.addChild(destVC)
        destVC.petOrVeterinary = "pet"
        destVC.view.frame = self.view.frame
        self.view.addSubview(destVC.view)
        destVC.didMove(toParent: self)
    }
}
// MARK: - extension for UIPickerView
extension NewPetViewController: UIPickerViewDataSource, UIPickerViewDelegate {
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
            checkChangeDone()
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
            checkChangeDone()
//            petRaceField.resignFirstResponder()
        }
    }
}

// MARK: - extension for getting image
extension NewPetViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    func imagePicker(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
        if error != nil {
            getErrors(type: .saveFailed)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        var selectedImageFromPicker: UIImage?

        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }

        if let selectedImage = selectedImageFromPicker {
            petPicture.image = selectedImage
            checkPetComplete()
        }
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_
        input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }
}

// MARK: - UITextFieldDelegate
extension NewPetViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        typeFieldOrView = "UITextField"
        activeField = textField
        activeField?.textColor = #colorLiteral(red: 1, green: 0.2730214596, blue: 0.2258683443, alpha: 1)
        lastOffset = self.scrollView.contentOffset
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        activeField?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        activeField?.resignFirstResponder()
        activeField = nil
        return true
    }
}
extension NewPetViewController: UITextViewDelegate {
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
        checkChangeDone()
        petBreederView.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        petBreederView.resignFirstResponder()
    }
}
// MARK: - Keyboard Handling
private extension NewPetViewController {
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
                //            if distanceToBottom < 0 {
                //                distanceToBottom = 0
                //            }
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
