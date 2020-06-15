//
//  PetViewController.swift
//  MDPet
//
//  Created by Philippe on 08/02/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit
import Firebase
//import FirebaseStorage

// MARK: - class PetViewController
class PetViewController: UIViewController {

// MARK: - outlets
    ///   link between view elements and controller
    @IBOutlet weak var petTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var petPicture: UIImageView!
    @IBOutlet weak var petNameField: UITextField!
    @IBOutlet weak var petGenderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var petBirthDateField: UITextField!
    @IBOutlet weak var petTatooField: UITextField!
    @IBOutlet weak var petSterilizedSwitch: UISwitch!
    @IBOutlet weak var petSterilizedDateField: UITextField!
    @IBOutlet weak var petVeterinaryField: UITextField!
    @IBOutlet weak var petRaceField: UITextField!
    @IBOutlet weak var petWeaningSwitch: UISwitch!
    @IBOutlet weak var petWeaningDateField: UITextField!
    @IBOutlet weak var petDeathDateField: UITextField!

    @IBOutlet weak var savePetButton: UIBarButtonItem!

// MARK: - variables
    private let imagePicker = UIImagePickerController()
    private var petName: UITextField?
    private var pickerViewGender = UIPickerView()
    private var datePickerBirthDate: UIDatePicker?
    private var petSterilized: UISwitch?
    private var datePickerSterilized: UIDatePicker?
    private var petWeaning: UISwitch?
    private var datePickerWeaning: UIDatePicker?
    private var datePickerDeathDate: UIDatePicker?
    private var pickerViewVeterinary = UIPickerView()
    private var pickerViewRace = UIPickerView()
    private var activeField: UITextField?
    private var lastOffset: CGPoint!
    private var keyboardHeight: CGFloat!
    private var constraintContentHeight: CGFloat!
    private let localeLanguage = Locale(identifier: "FR-fr")
    private var dateFormatter = DateFormatter()
    private var selectedVeterinary: String = ""
    private var selectedRace: String = ""
    private var selectedVeterinaryKey: String = ""

    var veterinariesItems: [VeterinaryItem] = []
    var typeOfCall: String = ""
    var petItem: PetItem?
    var petKey: String = ""
    var databaseRef = Database.database().reference(withPath: "pets-item")
    var imageRef = Storage.storage().reference().child("pets-images")
    let usersRef = Database.database().reference(withPath: "online")
    let imageCache = NSCache<NSString, AnyObject>()
    private var pathPet: String = ""

// MARK: - buttons
    ///   
    @IBAction func addPetPhoto(_ sender: Any) {
        selectImageOrCamera(animated: true)
    }

    @IBAction func savePet(_ sender: Any) {
        createOrUpdatePet()
    }

    @IBAction func suppressPet(_ sender: Any) {
        getSuppressedPet()
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
        initiateVeterinariesList()
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .navigationBarPetToTrue, object: nil)
    }

// MARK: - @objc func
    @objc func returnTextView(gesture: UIGestureRecognizer) {
        guard activeField != nil else {
            return
        }
        activeField?.resignFirstResponder()
        activeField = nil
    }
    @objc func navigationBarPetToTrue(notification: Notification) {
        navigationController?.navigationBar.isUserInteractionEnabled = true
    }
    @objc func textChangedPetTypeSegmentedCtrl(typeSegmentedCtrl: UISegmentedControl) {
        checkChangeDone()
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
        checkChangeDone()
        formatDate()
        petSterilizedDateField.text = dateFormatter.string(from: datePicker.date)
    }
    @objc func petVeterinaryFieldDidChange(_ textField: UITextField) {
        checkChangeDone()
    }
    @objc func petRaceFieldDidChange(_ textField: UITextField) {
        checkChangeDone()
    }
    @objc func petWeaningSwitchDidChange(_ textField: UISwitch) {
        if petWeaningSwitch.isOn == true {
            petWeaningDateField.isEnabled = true
            petWeaningDateField.text = petItem?.petSterilizedDate
        } else {
            petWeaningDateField.isEnabled = false
            petWeaningDateField.text =  ""
        }
        checkChangeDone()
    }
    @objc func dateChangedWeaning(datePicker: UIDatePicker) {
        checkChangeDone()
        formatDate()
        petWeaningDateField.text = dateFormatter.string(from: datePicker.date)
    }
    @objc func dateChangedDeathDate(datePicker: UIDatePicker) {
        checkChangeDone()
        formatDate()
        petDeathDateField.text = dateFormatter.string(from: datePicker.date)
    }

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
        if petTatooField.text != petItem?.petTatoo {
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
        if petVeterinaryField.text != petItem?.petVeterinary {
            toggleSavePetButton(shown: true)
            return
        }
        if petRaceField.text != petItem?.petRace {
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
    private func formatDate() {
        dateFormatter.locale = localeLanguage
        dateFormatter.dateFormat = "dd MMMM yyyy"
    }

// MARK: - functions
    private func createObserver() {
        createObserverPetTypeSegmentedCtrl()
        createObserverPetName()
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
        petBirthDateField.delegate = self
        petTatooField.delegate = self
        petSterilizedDateField.delegate = self
        petVeterinaryField.delegate = self
        petRaceField.delegate = self
        petWeaningDateField.delegate = self
        petDeathDateField.delegate = self
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
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                              action: #selector(returnTextView(gesture:))))
    }
    private func initiateView() {
        if typeOfCall == "create" {
            savePetButton.title = "Ajouter"
        } else {
            savePetButton.title = "Modifier"
        }
        initiatePictureView()
    }
    private func initiatePictureView() {
        petPicture.image = nil
        if let URLPicture = petItem?.petURLPicture {
//            GetFirebasePicture.shared.getPicture(URLPicture: URLPicture) { (success, picture) in
//                if success, let picture = picture {
//                    self.petPicture.image = picture
//                }
//                self.initiateFieldsView()
//            }
            if let cachedImage = imageCache.object(forKey: URLPicture as NSString) as? UIImage {
                petPicture.image = cachedImage
                return
            }
            let url = URL(string: URLPicture)
            if url != nil {
                URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                    if let error = error {
                        print(error)
                        return
                    }
                    guard response != nil else {
                        return
                    }
                    DispatchQueue.main.async(execute: {
                        if let downloadedImage = UIImage(data: data!) {
                            self.imageCache.setObject(downloadedImage, forKey: URLPicture as NSString)
                            self.petPicture.image = downloadedImage
                        }
                    })
                }).resume()
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

        petVeterinaryField.text = getVeterinaryNameFromKey()
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
    }
    private func getVeterinaryNameFromKey() -> String {
        for indice in 0...veterinariesItems.count-1
            where veterinariesItems[indice].key == petItem?.petVeterinary {
                return veterinariesItems[indice].veterinaryName
        }
        return ""
    }
    private func initiateVeterinariesList() {
        let pathVeterinary = UserUid.uid + "-veterinaries-item"

        databaseRef = Database.database().reference(withPath: "\(pathVeterinary)")

        databaseRef.queryOrdered(byChild: "veterinaryName").observe(.value, with: { snapshot in
            var newItems: [VeterinaryItem] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                    let veterinaryItem = VeterinaryItem(snapshot: snapshot) {
                    newItems.append(veterinaryItem)
                }
            }
            self.veterinariesItems = newItems
        })
        usersRef.observe(.value, with: { snapshot in
            self.initiateView()
            //          if snapshot.exists() {
            //            self.userCountBarButtonItem?.title = snapshot.childrenCount.description
            //          } else {
            //            self.userCountBarButtonItem?.title = "0"
            //          }
        })
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
            savePetButton.tintColor = #colorLiteral(red: 1, green: 0.2730214596, blue: 0.2258683443, alpha: 1)
        case false:
            savePetButton.tintColor = #colorLiteral(red: 0.7256230712, green: 0.725236237, blue: 0.7426275611, alpha: 1)
        }
    savePetButton.isEnabled = shown
    savePetButton.isAccessibilityElement = shown
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
//            dismiss(animated: true, completion: nil)
        } else {
            updatePetStorage(petURLPicture: "", uniqueUUID: uniqueUUID)
        }
        dismiss(animated: true, completion: nil)
        toggleSavePetButton(shown: false)
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
            deathDate: String(petDeathDateField.text ?? ""))
        let petItemRef = databaseRef.child(uniqueUUID)
        petItemRef.setValue(petItem?.toAnyObject())
    }
    private func getSuppressedPet() {
        navigationController?.navigationBar.isUserInteractionEnabled = false
        guard let destVC = self.storyboard?.instantiateViewController(withIdentifier: "confirmPetSuppress")
            as? ConfirmPetSuppressViewController else {
                return
        }
        destVC.petKey = petKey
        self.addChild(destVC)
        destVC.view.frame = self.view.frame
        self.view.addSubview(destVC.view)
        destVC.didMove(toParent: self)
    }
}

extension PetViewController {
    private func createObserverPetName() {
        petNameField?.addTarget(self,
                                action: #selector(PetViewController.petNameFieldDidChange(_:)),
                                for: .editingChanged)
    }
    private func createObserverPetTatoo() {
        petTatooField?.addTarget(self,
                                action: #selector(PetViewController.petTatooFieldDidChange(_:)),
                                for: .editingChanged)
    }
    private func createObserverDatePickerBirthDate() {
        datePickerBirthDate = UIDatePicker()
        datePickerBirthDate?.datePickerMode = .date
        datePickerBirthDate?.locale = localeLanguage
        datePickerBirthDate?.addTarget(self,
                                       action: #selector(PetViewController.dateChangedBirthDate(datePicker:)),
                                       for: .valueChanged)
        petBirthDateField.inputView = datePickerBirthDate
    }
    private func createObserverSterilizedSwitch() {
        petSterilizedSwitch?.addTarget(self,
                                action: #selector(PetViewController.petSterilizedSwitchDidChange(_:)),
                                for: .touchUpInside)
    }
    private func createObserverDatePickerSterilized() {
        datePickerSterilized = UIDatePicker()
        datePickerSterilized?.datePickerMode = .date
        datePickerSterilized?.locale = localeLanguage
        datePickerSterilized?.addTarget(self,
                                       action: #selector(PetViewController.dateChangedSterilized(datePicker:)),
                                       for: .valueChanged)
        petSterilizedDateField.inputView = datePickerSterilized
    }
    private func createObserverWeaningSwitch() {
        petWeaningSwitch?.addTarget(self,
                                action: #selector(PetViewController.petWeaningSwitchDidChange(_:)),
                                for: .touchUpInside)
    }
    private func createObserverDatePickerWeaning() {
        datePickerWeaning = UIDatePicker()
        datePickerWeaning?.datePickerMode = .date
        datePickerWeaning?.locale = localeLanguage
        datePickerWeaning?.addTarget(self,
                                       action: #selector(PetViewController.dateChangedWeaning(datePicker:)),
                                       for: .valueChanged)
        petWeaningDateField.inputView = datePickerWeaning
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
                                action: #selector(PetViewController.petRaceFieldDidChange(_:)),
                                for: .editingChanged)
        petRaceField.inputView = pickerViewRace
    }
    private func createObserverVeterinaryPickerView() {
        pickerViewVeterinary.delegate = self
        petVeterinaryField?.addTarget(self,
                                action: #selector(PetViewController.petVeterinaryFieldDidChange(_:)),
                                for: .valueChanged )
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
            selectedVeterinary = veterinariesItems[row].veterinaryName
            selectedVeterinaryKey = veterinariesItems[row].key
            petVeterinaryField.text = selectedVeterinary
            checkChangeDone()
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
        }
    }
}

// MARK: - extension for getting image
extension PetViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

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
extension PetViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        lastOffset = view.frame.origin
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        activeField?.resignFirstResponder()
        activeField = nil
        return true
    }
}

// MARK: - Keyboard Handling
private extension PetViewController {
    @objc private func keyboardWillShow(notification: NSNotification) {
        if keyboardHeight != nil {
            return
        }
        if let keyboardSize =
            (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height + 40
            constraintContentHeight = keyboardHeight + view.frame.size.height

            // move if keyboard hide input field
            let distanceToBottom =
                self.view.frame.size.height - (activeField?.frame.origin.y)! - (activeField?.frame.size.height)!
            if distanceToBottom > keyboardHeight {
                return
            }
            let collapseSpace = (keyboardHeight - distanceToBottom + 10) * -1
            // set new offset for scroll view
            UIView.animate(withDuration: 0.3, animations: {
                self.view.frame.origin = CGPoint(x: self.lastOffset.x, y: collapseSpace)
            })
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin = CGPoint(x: 0, y: 0)
        }
        keyboardHeight = nil
    }
}
