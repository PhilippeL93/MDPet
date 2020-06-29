//
//  vaccineViewController.swift
//  MDPet
//
//  Created by Philippe on 26/06/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit
import Firebase

class VaccineViewController: UIViewController {

    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var vaccineInjectionField: UITextField!
    @IBOutlet weak var vaccineDateField: UITextField!
    @IBOutlet weak var vaccineNameField: UITextField!
    @IBOutlet weak var vaccineVeterinaryField: UITextField!
    @IBOutlet weak var diseaseOneLabel: UILabel!
    @IBOutlet weak var diseaseTwoLabel: UILabel!
    @IBOutlet weak var diseaseThreeLabel: UILabel!
    @IBOutlet weak var diseaseFourLabel: UILabel!
    @IBOutlet weak var diseaseFiveLabel: UILabel!
    @IBOutlet weak var diseaseSixLabel: UILabel!
    @IBOutlet weak var diseaseSevenLabel: UILabel!
    @IBOutlet weak var diseaseEightLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var saveVaccineButton: UIBarButtonItem!

    // MARK: - variables
    private var activeField: UITextField?

    var typeOfCall: String = ""
    var vaccineItem: VaccineItem?
    var diseases: Diseases?
    var vaccineKey: String = ""
    var databaseRef = Database.database().reference(withPath: "vaccines-item")
    var imageRef = Storage.storage().reference().child("pets-images")
//    private var pathVaccine: String = ""

    // MARK: - buttons

    @IBAction func addThumbnailVaccine(_ sender: Any) {
//        selectImageOrCamera(animated: true)
    }
    @IBAction func saveVaccine(_ sender: Any) {
        createOrUpdateVaccine()
    }
    @IBAction func backToVaccines(_ sender: UIBarButtonItem) {
        activeField?.resignFirstResponder()
        activeField = nil
        checkUpdateVaccinesDone()
    }
    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        let path = UserUid.uid + "-vaccines-item"
        databaseRef = Database.database().reference(withPath: "\(path)")
//        createObserver()
//        createDelegate()
//        toggleSaveVeterinaryButton(shown: false)
//        initiateObserver()
//        initiateView()
    }
    // MARK: - functions
    private func checkUpdateVaccinesDone() {
        if saveVaccineButton.isEnabled == false {
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
        private func createOrUpdateVaccine() {
//            databaseRef = Database.database().reference(withPath: "\(pathVaccine)")
//            guard let petKey = petItem?.key else {
//                return
//            }
//            var storageRef = imageRef.child("\(String(describing: petKey)).png")
            var uniqueUUID = vaccineKey

            if typeOfCall == "create" {
                uniqueUUID = UUID().uuidString
//                storageRef = imageRef.child("\(String(describing: uniqueUUID)).png")
            }
//
//            if let uploadData = self.vaccinePicture.image?.pngData() {
//                storageRef.putData(uploadData, metadata: nil, completion: { (_, error) in
//                    if let error = error {
//                        print(error)
//                        return
//                    }
//                    storageRef.downloadURL(completion: { (url, err) in
//                        if let err = err {
//                            print(err)
//                            return
//                        }
//                        let vaccineURLThumbnail = (url?.absoluteString) ?? ""
//                        self.updateVaccineStorage(vaccineURLThumbnail: vaccineURLThumbnail, uniqueUUID: uniqueUUID)
//                    })
//                })
//            } else {
                updateVaccineStorage(vaccineURLThumbnail: "", uniqueUUID: uniqueUUID)
//            }
            navigationController?.popViewController(animated: true)
        }
    private func updateVaccineStorage(vaccineURLThumbnail: String, uniqueUUID: String) {
        let vaccineDiseases = catDiseases
        vaccineItem = VaccineItem(
            name: "name",
            number: 1,
            injection: "injection",
            date: "28 juin 2020",
            URLThumbnail: "fffffffffff",
            veterinary: "veto",
            diseases: vaccineDiseases)
        let vaccineItemRef = databaseRef.child(uniqueUUID)
        vaccineItemRef.setValue(vaccineItem?.toAnyObject())
        }
    private func checkVaccineComplete() {
//        guard let petName = petNameField.text else {
//            return
//        }
//        guard !petName.isEmpty else {
//            return
//        }
//        guard let petBirthDate = petBirthDateField.text else {
//            return
//        }
//        guard !petBirthDate.isEmpty else {
//            return
//        }
//        guard (thumbnailImageView.image?.pngData()) != nil else {
//            return
//        }
        toggleSavePetButton(shown: true)
    }
    private func toggleSavePetButton(shown: Bool) {
        switch shown {
        case true:
            saveVaccineButton.isEnabled = true
        case false:
            saveVaccineButton.isEnabled = false
        }
    saveVaccineButton.isEnabled = shown
    saveVaccineButton.isAccessibilityElement = shown
    }
}

extension VaccineViewController {
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

// MARK: - extension for getting image
extension VaccineViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

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
            thumbnailImageView.image = selectedImage
            checkVaccineComplete()
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
