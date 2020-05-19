//
//  PetsViewController.swift
//  MDPet
//
//  Created by Philippe on 08/02/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit

// MARK: - class PetsViewController
class PetsViewController: UIViewController {

// MARK: - outlets
    ///   link between view elements and controller
    @IBOutlet weak var petTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var imagePetLabel: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var birthDateText: UITextField!
    @IBOutlet weak var tatooText: UITextField!
    @IBOutlet weak var sterilizedSwitch: UISwitch!
    @IBOutlet weak var dateSterilizedText: UITextField!
    @IBOutlet weak var veterinaryText: UITextField!
    @IBOutlet weak var raceText: UITextField!
    @IBOutlet weak var weaningSwitch: UISwitch!
    @IBOutlet weak var weaningDateText: UITextField!
    @IBOutlet weak var deathDateText: UITextField!
    @IBOutlet weak var savePetButton: UIBarButtonItem!

// MARK: - variables
    private var datePickerBirthDate: UIDatePicker?
    private var datePickerSterilized: UIDatePicker?
    private var datePickerWeaning: UIDatePicker?
    private var datePickerDeathDate: UIDatePicker?
    private var pickerViewBreed = UIPickerView()
    private var pickerViewVeterinary = UIPickerView()
    private let imagePicker = UIImagePickerController()
    private var activeField: UITextField?
    private var lastOffset: CGPoint!
    private var keyboardHeight: CGFloat!
    private var constraintContentHeight: CGFloat!
    private let localeLanguage = Locale(identifier: "FR-fr")
    private var dateFormatter = DateFormatter()
    private var pets: Pets?

// MARK: - buttons
    ///   saveSettings in order to save in userDefaults
    @IBAction func addPetPhoto(_ sender: Any) {
        selectImageOrCamera(animated: true)
    }
    @IBAction func savePet(_ sender: Any) {
//        createPetObject()
//        checkPetStatus()
    }
    @IBAction func suppressPet(_ sender: Any) {
    }

// MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        createPickerView()
        createDelegate()
        toggleSavePetButton(shown: false)
        initiateObserver()
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }

// MARK: - @objc func
    @objc func returnTextView(gesture: UIGestureRecognizer) {
        guard activeField != nil else {
            return
        }
        activeField?.resignFirstResponder()
        activeField = nil
    }

    @objc func dateChangedBirthDate(datePicker: UIDatePicker) {
        formatDate()
        birthDateText.text = dateFormatter.string(from: datePicker.date)
    }
    @objc func dateChangedSterilized(datePicker: UIDatePicker) {
        formatDate()
        dateSterilizedText.text = dateFormatter.string(from: datePicker.date)
    }
    @objc func dateChangedWeaning(datePicker: UIDatePicker) {
        formatDate()
        weaningDateText.text = dateFormatter.string(from: datePicker.date)
    }
    @objc func dateChangedDeathDate(datePicker: UIDatePicker) {
        formatDate()
        deathDateText.text = dateFormatter.string(from: datePicker.date)
    }
    private func formatDate() {
        dateFormatter.locale = localeLanguage
        dateFormatter.dateFormat = "dd MMMM yyyy"
    }

    @objc func textChangedPetTypeSegmentedCtrl(typeSegmentedCtrl: UISegmentedControl) {
        self.pickerViewBreed.reloadAllComponents()
    }

// MARK: - functions
    private func createPickerView() {
        createDatePickerBirthDate()
        createDatePickerSterilized()
        createDatePickerWeaning()
        createDatePickerDeathDate()
        createBreedPickerView()
        createVeterinaryPickerView()
        createPetTypeSegmentedCtrl()
    }
    private func createDelegate() {
        nameText.delegate = self
        tatooText.delegate = self
        birthDateText.delegate = self
        dateSterilizedText.delegate = self
        veterinaryText.delegate = self
        weaningDateText.delegate = self
        raceText.delegate = self
        deathDateText.delegate = self
    }
    private func initiateObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                              action: #selector(returnTextView(gesture:))))
    }
    private func createDatePickerBirthDate() {
        datePickerBirthDate = UIDatePicker()
        datePickerBirthDate?.datePickerMode = .date
        datePickerBirthDate?.locale = localeLanguage
        datePickerBirthDate?.addTarget(self,
                                       action: #selector(PetsViewController.dateChangedBirthDate(datePicker:)),
                                       for: .valueChanged)
        birthDateText.inputView = datePickerBirthDate
    }
    private func createDatePickerSterilized() {
        datePickerSterilized = UIDatePicker()
        datePickerSterilized?.datePickerMode = .date
        datePickerSterilized?.locale = localeLanguage
        datePickerSterilized?.addTarget(self,
                                       action: #selector(PetsViewController.dateChangedSterilized(datePicker:)),
                                       for: .valueChanged)
        dateSterilizedText.inputView = datePickerSterilized
    }
    private func createDatePickerWeaning() {
        datePickerWeaning = UIDatePicker()
        datePickerWeaning?.datePickerMode = .date
        datePickerWeaning?.locale = localeLanguage
        datePickerWeaning?.addTarget(self,
                                       action: #selector(PetsViewController.dateChangedWeaning(datePicker:)),
                                       for: .valueChanged)
        weaningDateText.inputView = datePickerWeaning
    }
    private func createDatePickerDeathDate() {
        datePickerDeathDate = UIDatePicker()
        datePickerDeathDate?.datePickerMode = .date
        datePickerDeathDate?.locale = localeLanguage
        datePickerDeathDate?.addTarget(self,
                                       action: #selector(PetsViewController.dateChangedDeathDate(datePicker:)),
                                       for: .valueChanged)
        deathDateText.inputView = datePickerDeathDate
    }
    private func createBreedPickerView() {
        pickerViewBreed.delegate = self
        raceText.inputView = pickerViewBreed
    }
    private func createVeterinaryPickerView() {
        pickerViewVeterinary.delegate = self
        veterinaryText.inputView = pickerViewVeterinary
    }
    private func createPetTypeSegmentedCtrl() {
        petTypeSegmentedControl?.addTarget(self,
                                       action: #selector(
                                       PetsViewController.textChangedPetTypeSegmentedCtrl(typeSegmentedCtrl:)),
                                       for: .valueChanged)
    }

    private func checkPetComplete() {
        guard let imagePet = (imagePetLabel.image)?.pngData() else {
            return
        }
        let petTypeIndex = petTypeSegmentedControl.selectedSegmentIndex
        let petType: Pets.PetType = (petTypeIndex == 0) ? .cat : .rodent
        guard let name = nameText.text else {
            return
        }
        let genderIndex = genderSegmentedControl.selectedSegmentIndex
        let gender: Pets.Gender = (genderIndex == 0) ? .female : .male
        guard let birdthDate = birthDateText.text else {
            return
        }
        guard let tatoo = tatooText.text else {
            return
        }
        let sterilized = sterilizedSwitch.isOn
        guard let sterilizedDate = dateSterilizedText.text else {
            return
        }
        guard let veterinary = dateSterilizedText.text else {
            return
        }
        guard let race = raceText.text else {
            return
        }
        let weaning = weaningSwitch.isOn
        guard let weaningDate = weaningDateText.text else {
            return
        }
        guard let deathDate = deathDateText.text else {
            return
        }
        pets = Pets(imagePet: imagePet,
                    petType: petType,
                    name: name,
                    gender: gender,
                    birdthDate: birdthDate,
                    tatoo: tatoo,
                    sterilized: sterilized,
                    sterilizedDate: sterilizedDate,
                    veterinary: veterinary,
                    race: race,
                    weaning: weaning,
                    weaningDate: weaningDate,
                    deathDate: deathDate)
        toggleSavePetButton(shown: true)
    }
    private func toggleSavePetButton(shown: Bool) {
        switch shown {
        case true:
            savePetButton.tintColor = #colorLiteral(red: 0.6904090591, green: 0.9153559804, blue: 0, alpha: 1)
        case false:
            savePetButton.tintColor = #colorLiteral(red: 0.8214782803, green: 1, blue: 0.6659395258, alpha: 1)
        }
    savePetButton.isEnabled = shown
    savePetButton.isAccessibilityElement = shown
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
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true)
    }
}

// MARK: - extension for UIPickerView
extension PetsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pickerViewVeterinary {
            return 0
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
            return nil
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
        var selected: String = ""
        if pickerView == pickerViewVeterinary {
            selected = ""
            veterinaryText.text = selected
        } else {
            switch petTypeSegmentedControl.selectedSegmentIndex {
            case 0:
                selected = catRaces[row]
            case 1:
                selected = dogRaces[row]
            case 2:
                selected = rabbitRaces[row]
            case 3:
                selected = rodentRaces[row]
            default:
                selected = ""
            }
            raceText.text = selected
        }
    }
}

// MARK: - extension for getting image
extension PetsViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    func imagePicker(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
        if error != nil {
            getErrors(type: .saveFailed)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePetLabel.contentMode = .scaleAspectFit
            imagePetLabel.image = pickedImage
            checkPetComplete()
        }
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate
extension PetsViewController: UITextFieldDelegate {
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
private extension PetsViewController {
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
        checkPetComplete()
    }
}
