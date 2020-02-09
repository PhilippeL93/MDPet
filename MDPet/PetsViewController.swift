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
    @IBOutlet weak var imagePet: UIImageView!
    @IBOutlet weak var petTypeSegmentedCtrl: UISegmentedControl!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var petSexeSegmentedCtrl: UISegmentedControl!
    @IBOutlet weak var birthDateText: UITextField!
    @IBOutlet weak var tatooText: UITextField!
    @IBOutlet weak var sterilizedSwitch: UISwitch!
    @IBOutlet weak var dateSterilizedText: UITextField!
    @IBOutlet weak var veterinaryText: UITextField!
    @IBOutlet weak var breedText: UITextField!

    @IBOutlet weak var weaningSwitch: UISwitch!
    @IBOutlet weak var weaningDateText: UITextField!
    @IBOutlet weak var deathDateText: UITextField!

    @IBAction func dismissKeyBoard(_ sender: UITapGestureRecognizer) {
        nameText.resignFirstResponder()
        tatooText.resignFirstResponder()
        birthDateText.resignFirstResponder()
        dateSterilizedText.resignFirstResponder()
        veterinaryText.resignFirstResponder()
        weaningDateText.resignFirstResponder()
        breedText.resignFirstResponder()
        deathDateText.resignFirstResponder()
    }

    // MARK: - buttons
    ///   saveSettings in order to save in userDefaults
    @IBAction func addPetPhoto(_ sender: Any) {
        selectImageOrCamera(animated: true)
    }
    @IBAction func savePet(_ sender: Any) {
    }
    @IBAction func suppressPet(_ sender: Any) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        createDatesPickerView()
        createBreedPickerView()
        createVeterinaryPickerView()
    }

    // MARK: - variables
    private var datePickerBirthDate: UIDatePicker?
    private var datePickerSterilized: UIDatePicker?
    private var datePickerWeaning: UIDatePicker?
    private var datePickerDeathDate: UIDatePicker?
    private var pickerViewBreed = UIPickerView()
    private var pickerViewVeterinary = UIPickerView()
    private let imagePicker = UIImagePickerController()

    @objc func dateChangedBirthDate(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        birthDateText.text = dateFormatter.string(from: datePicker.date)
    }
    @objc func dateChangedSterilized(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        dateSterilizedText.text = dateFormatter.string(from: datePicker.date)
    }
    @objc func dateChangedWeaning(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        weaningDateText.text = dateFormatter.string(from: datePicker.date)
    }
    @objc func dateChangedDeathDate(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        deathDateText.text = dateFormatter.string(from: datePicker.date)
    }

    // MARK: - functions
    private func createDatesPickerView() {
        createDatePickerBirthDate()
        createDatePickerSterilized()
        createDatePickerWeaning()
        createDatePickerDeathDate()
    }
    private func createDatePickerBirthDate() {
        datePickerBirthDate = UIDatePicker()
        datePickerBirthDate?.datePickerMode = .date
        datePickerBirthDate?.addTarget(self,
                                       action: #selector(PetsViewController.dateChangedBirthDate(datePicker:)),
                                       for: .valueChanged)
        birthDateText.inputView = datePickerBirthDate
    }
    private func createDatePickerSterilized() {
        datePickerSterilized = UIDatePicker()
        datePickerSterilized?.datePickerMode = .date
        datePickerSterilized?.addTarget(self,
                                       action: #selector(PetsViewController.dateChangedSterilized(datePicker:)),
                                       for: .valueChanged)
        dateSterilizedText.inputView = datePickerSterilized
    }
    private func createDatePickerWeaning() {
        datePickerWeaning = UIDatePicker()
        datePickerWeaning?.datePickerMode = .date
        datePickerWeaning?.addTarget(self,
                                       action: #selector(PetsViewController.dateChangedWeaning(datePicker:)),
                                       for: .valueChanged)
        weaningDateText.inputView = datePickerWeaning
    }
    private func createDatePickerDeathDate() {
        datePickerDeathDate = UIDatePicker()
        datePickerDeathDate?.datePickerMode = .date
        datePickerDeathDate?.addTarget(self,
                                       action: #selector(PetsViewController.dateChangedDeathDate(datePicker:)),
                                       for: .valueChanged)
        deathDateText.inputView = datePickerDeathDate
    }

    private func createBreedPickerView() {
        pickerViewBreed.delegate = self
        breedText.inputView = pickerViewBreed
    }
    private func createVeterinaryPickerView() {
        pickerViewVeterinary.delegate = self
        veterinaryText.inputView = pickerViewVeterinary
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
        self.present(alert, animated: true, completion: {
        })
    }

    ///   getImage in order to call imagePickerController
    ///     - if photo direct imagePickerController with source photoLibrary
    ///     - if camera verifying available on this device
    ///         - if camera available call of imagePickerController with source camera
    ///             - else noCamera
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
                noCamera()
            }
        default:
            break
        }
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true)
    }

    ///    noCamera display message when device has no camera
    private func noCamera() {
        let alertVC = UIAlertController(
            title: "Pas d'appareil photo",
            message: "Désolé, cet appareil n'a pas d'appareil photo",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil)
        alertVC.addAction(okAction)
        present(
            alertVC,
            animated: true,
            completion: nil)
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
            switch petTypeSegmentedCtrl.selectedSegmentIndex {
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
            switch petTypeSegmentedCtrl.selectedSegmentIndex {
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
            switch petTypeSegmentedCtrl.selectedSegmentIndex {
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
            breedText.text = selected
        }
    }
}

extension PetsViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    /*    function imagePickerController
     */

    func imagePicker(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
        if error != nil {
            let alert = UIAlertController(title: "Save Failed",
                                          message: "Failed to save image",
                                          preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "OK",
                                             style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            self.present(alert, animated: true,
                         completion: nil)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePet.contentMode = .scaleAspectFit
            imagePet.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
