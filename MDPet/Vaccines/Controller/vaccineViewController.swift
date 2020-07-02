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
    @IBOutlet weak var switchOne: UISwitch!
    @IBOutlet weak var diseaseTwoLabel: UILabel!
    @IBOutlet weak var switchTwo: UISwitch!
    @IBOutlet weak var diseaseThreeLabel: UILabel!
    @IBOutlet weak var switchThree: UISwitch!
    @IBOutlet weak var diseaseFourLabel: UILabel!
    @IBOutlet weak var switchFour: UISwitch!
    @IBOutlet weak var diseaseFiveLabel: UILabel!
    @IBOutlet weak var switchFive: UISwitch!
    @IBOutlet weak var diseaseSixLabel: UILabel!
    @IBOutlet weak var switchSix: UISwitch!
    @IBOutlet weak var diseaseSevenLabel: UILabel!
    @IBOutlet weak var switchSeven: UISwitch!
    @IBOutlet weak var diseaseEightLabel: UILabel!
    @IBOutlet weak var switchEight: UISwitch!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var saveVaccineButton: UIBarButtonItem!

    @IBOutlet weak var scrollView: UIScrollView!

    // MARK: - variables
    private let imagePicker = UIImagePickerController()
    private var vaccineInjection: UITextField?
    private var datePickerVaccineDate: UIDatePicker?
    private var vaccineName: UITextField?
    private var pickerViewVeterinary = UIPickerView()
    private var diseaseSwitchOne: UISwitch?
    private var diseaseSwitchTwo: UISwitch?
    private var diseaseSwitchThree: UISwitch?
    private var diseaseSwitchFour: UISwitch?
    private var diseaseSwitchFive: UISwitch?
    private var diseaseSwitchSix: UISwitch?
    private var diseaseSwitchSeven: UISwitch?
    private var diseaseSwitchEight: UISwitch?
    private var activeField: UITextField?
    private var lastOffset: CGPoint!
    private var keyboardHeight: CGFloat!
    private var constraintContentHeight: CGFloat!
    private let localeLanguage = Locale(identifier: "FR-fr")
    private var dateFormatter = DateFormatter()
    private var selectedRace: String = ""
    private var selectedVeterinaryKey: String = ""

    var veterinariesItems: [VeterinaryItem] = []
    var typeOfCall: String = ""
    var petItem: PetItem?
    var vaccineKey: String = ""
    var vaccineItem: VaccineItem?
//    var diseases: Diseases?
    var databaseRef = Database.database().reference(withPath: "vaccines-item")
    var imageRef = Storage.storage().reference().child("pets-images")
    var diseasesPet: DiseaseByVaccine?
    private var pathVaccine: String = ""

    // MARK: - buttons

    @IBAction func addThumbnailButton(_ sender: Any) {
        selectImageOrCamera(animated: true)
    }
    @IBAction func saveVaccine(_ sender: Any) {
        createOrUpdateVaccine()
    }
    @IBAction func backToVaccines(_ sender: UIBarButtonItem) {
        activeField?.resignFirstResponder()
        activeField = nil
        checkUpdateVaccinesDone()
    }
    @IBAction func veterinaryEditingDidBegin(_ sender: Any) {
        if !vaccineVeterinaryField.text!.isEmpty {
            let rowVeterinary = getVeterinaryNameFromKey(veterinaryToSearch: selectedVeterinaryKey)
            pickerViewVeterinary.selectRow(rowVeterinary, inComponent: 0, animated: true)
        } else {
            pickerViewVeterinary.selectRow(0, inComponent: 0, animated: true)
        }
    }
    @IBAction func vaccineDateEditingDidBegin(_ sender: Any) {
        formatDate()
        if vaccineDateField.text!.isEmpty {
            let date = Date()
            vaccineDateField.text = dateFormatter.string(from: date)
        } else {
            let  vaccineDate = dateFormatter.date(from: vaccineDateField.text!)
            datePickerVaccineDate?.date = vaccineDate!
        }
    }
    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        pathVaccine = UserUid.uid + petItem!.key + "-vaccines-item"
        databaseRef = Database.database().reference(withPath: "\(pathVaccine)")
        petNameLabel.text = petItem?.petName
        createObserver()
        createDelegate()
        toggleSaveVaccineButton(shown: false)
        initiateObserver()
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
        initiateView()
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .navigationBarVaccineToTrue, object: nil)
        NotificationCenter.default.removeObserver(self, name: .isToUpdate, object: nil)
        NotificationCenter.default.removeObserver(self, name: .hasBeenDeleted, object: nil)
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
    @objc func vaccineInjectionFieldDidChange(_ textField: UITextField) {
        checkChangeDone()
    }
    @objc func dateChangedVaccineDate(datePicker: UIDatePicker) {
        vaccineDateField.text = dateFormatter.string(from: datePicker.date)
        checkChangeDone()
        formatDate()
        vaccineDateField.text = dateFormatter.string(from: datePicker.date)
    }
    @objc func vaccineNameFieldDidChange(_ textField: UITextField) {
        checkChangeDone()
    }
    @objc func vaccineVeterinaryFieldDidChange(_ textField: UITextField) {
        checkChangeDone()
    }
    @objc func diseaseSwitchOneDidChange(_ textField: UISwitch) {
        checkChangeDone()
    }
    @objc func  diseaseSwitchTwoDidChange(_ textField: UISwitch) {
        checkChangeDone()
    }
    @objc func diseaseSwitchThreeDidChange(_ textField: UISwitch) {
        checkChangeDone()
    }
    @objc func diseaseSwitchFourDidChange(_ textField: UISwitch) {
        checkChangeDone()
    }
    @objc func diseaseSwitchFiveDidChange(_ textField: UISwitch) {
        checkChangeDone()
    }
    @objc func diseaseSwitchSixDidChange(_ textField: UISwitch) {
        checkChangeDone()
    }
    @objc func diseaseSwitchSevenDidChange(_ textField: UISwitch) {
        checkChangeDone()
    }
    @objc func diseaseSwitchEightDidChange(_ textField: UISwitch) {
        checkChangeDone()
    }
}
extension VaccineViewController {
    // MARK: - functions
    private func createObserver() {
        createObserverVaccineInjection()
        createObserverDatePickerVaccineDate()
        createObserverVaccineName()
        createObserverVeterinaryPickerView()
        createObserverSwitchOne()
        createObserverSwitchTwo()
        createObserverSwitchThree()
        createObserverSwitchFour()
        createObserverSwitchFive()
        createObserverSwitchSix()
        createObserverSwitchSeven()
        createObserverSwitchEight()
    }
    private func createDelegate() {
        vaccineInjectionField.delegate = self
        vaccineDateField.delegate = self
        vaccineNameField.delegate = self
        vaccineVeterinaryField.delegate = self
    }
    private func initiateObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(navigationBarVaccineToTrue),
                                               name: .navigationBarVaccineToTrue, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(isVaccineToUpdate),
                                               name: .isToUpdate, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(isVaccineDeleted),
//                                               name: .hasBeenDeleted, object: nil)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                              action: #selector(tapGestuireRecognizer(gesture:))))
    }
    private func initiateView() {
        if typeOfCall == "create" {
            saveVaccineButton.title = "Ajouter"
            self.title = "Nouveau vaccin"
//            suppressVaccineButton.isHidden = true
            switchOne.isOn = false
            switchOne.isHidden = true
            diseaseOneLabel.isHidden = true
            switchTwo.isOn = true
            switchTwo.isHidden = true
            diseaseTwoLabel.isHidden = true
            switchThree.isOn = false
            switchThree.isHidden = true
            diseaseThreeLabel.isHidden = true
            switchFour.isOn = false
            switchFour.isHidden = true
            diseaseFourLabel.isHidden = true
            switchFive.isOn = false
            switchFive.isHidden = true
            diseaseFiveLabel.isHidden = true
            switchSix.isOn = false
            switchSix.isHidden = true
            diseaseSixLabel.isHidden = true
            switchSeven.isOn = false
            switchSeven.isHidden = true
            diseaseSevenLabel.isHidden = true
            switchEight.isOn = false
            switchEight.isHidden = true
            diseaseEightLabel.isHidden = true
            var petType: [String] = []
            switch petItem?.petType {
            case 0:
                petType = catDiseases
            case 1:
                petType = dogDiseases
            case 2:
                petType = rabbitDiseases
            default:
                print("other")
            }
//            diseasesPet = DiseaseByVaccine(petName: petItem!.petName)
            diseasesPet = DiseaseByVaccine()
            for indice in 0...petType.count-1 {
                if indice == 0 {
                    switchOne.isOn = true
                    switchOne.isHidden = false
                    diseaseOneLabel.isHidden = false
                    diseaseOneLabel.text = petType[indice]
                    let diseaseSselected = DiseasesSelected(diseaseName: petType[indice], diseaseSwitch: true)
                    diseasesPet!.addDisease(diseaseSelected: diseaseSselected)
                }
                if indice == 1 {
                    switchTwo.isOn = true
                    switchTwo.isHidden = false
                    diseaseTwoLabel.isHidden = false
                    diseaseTwoLabel.text = petType[indice]
                    let diseaseSselected = DiseasesSelected(diseaseName: petType[indice], diseaseSwitch: true)
                    diseasesPet!.addDisease(diseaseSelected: diseaseSselected)
                }
                if indice == 2 {
                    switchThree.isOn = true
                    switchThree.isHidden = false
                    diseaseThreeLabel.isHidden = false
                    diseaseThreeLabel.text = petType[indice]
                    let diseaseSselected = DiseasesSelected(diseaseName: petType[indice], diseaseSwitch: true)
                    diseasesPet!.addDisease(diseaseSelected: diseaseSselected)
                }
                if indice == 3 {
                    switchFour.isOn = true
                    switchFour.isHidden = false
                    diseaseFourLabel.isHidden = false
                    diseaseFourLabel.text = petType[indice]
                    let diseaseSselected = DiseasesSelected(diseaseName: petType[indice], diseaseSwitch: true)
                    diseasesPet!.addDisease(diseaseSelected: diseaseSselected)
                }
                if indice == 4 {
                    switchFive.isOn = true
                    switchFive.isHidden = false
                    diseaseFiveLabel.isHidden = false
                    diseaseFiveLabel.text = petType[indice]
                    let diseaseSselected = DiseasesSelected(diseaseName: petType[indice], diseaseSwitch: true)
                    diseasesPet!.addDisease(diseaseSelected: diseaseSselected)
                }
                if indice == 5 {
                    switchSix.isOn = true
                    switchSix.isHidden = false
                    diseaseSixLabel.isHidden = false
                    diseaseSixLabel.text = petType[indice]
                    let diseaseSselected = DiseasesSelected(diseaseName: petType[indice], diseaseSwitch: true)
                    diseasesPet!.addDisease(diseaseSelected: diseaseSselected)
                }
                if indice == 6 {
                    switchSeven.isOn = true
                    switchSeven.isHidden = false
                    diseaseSevenLabel.isHidden = false
                    diseaseSevenLabel.text = petType[indice]
                    let diseaseSselected = DiseasesSelected(diseaseName: petType[indice], diseaseSwitch: true)
                    diseasesPet!.addDisease(diseaseSelected: diseaseSselected)
                }
                if indice == 7 {
                    switchEight.isOn = true
                    switchEight.isHidden = false
                    diseaseEightLabel.isHidden = false
                    diseaseEightLabel.text = petType[indice]
                    let diseaseSselected = DiseasesSelected(diseaseName: petType[indice], diseaseSwitch: true)
                    diseasesPet!.addDisease(diseaseSelected: diseaseSselected)
                }
            }
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
    private func initiateFieldsView() {
        vaccineKey = vaccineItem?.key ?? ""
        vaccineInjectionField.text = vaccineItem?.vaccineInjection
        vaccineDateField.text = vaccineItem?.vaccineDate
        vaccineNameField.text = vaccineItem?.vaccineName
        let rowVeterinary = getVeterinaryNameFromKey(veterinaryToSearch: vaccineItem!.vaccineVeterinary)
        if rowVeterinary != -1 {
            vaccineVeterinaryField.text = veterinariesItems[rowVeterinary].veterinaryName
        }
        selectedVeterinaryKey = vaccineItem?.vaccineVeterinary ?? ""

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
//        let vaccineDiseases = catDiseases
//        let vaccineDiseases = diseasesPet
        vaccineItem = VaccineItem(
            name: String(vaccineNameField.text ?? ""),
            key: "",
            number: 1,
            injection: String(vaccineInjectionField.text ?? ""),
            date: String(vaccineDateField.text ?? ""),
            URLThumbnail: vaccineURLThumbnail,
            veterinary: String(vaccineVeterinaryField.text ?? ""),
            diseases: diseasesPet!)
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
        guard (thumbnailImageView.image?.pngData()) != nil else {
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
    private func checkChangeDone() {

    }
    private func createObserverVaccineInjection() {
        vaccineInjectionField?.addTarget(self,
                                         action: #selector(VaccineViewController.vaccineInjectionFieldDidChange(_:)),
                                         for: .editingChanged)
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
                                         action: #selector(VaccineViewController.vaccineNameFieldDidChange(_:)),
                                         for: .editingChanged)
    }
    private func createObserverVeterinaryPickerView() {
        pickerViewVeterinary.delegate = self
        vaccineVeterinaryField?.addTarget(self,
                                action: #selector(VaccineViewController.vaccineVeterinaryFieldDidChange(_:)),
                                for: .editingChanged )
        vaccineVeterinaryField.inputView = pickerViewVeterinary
    }
    private func createObserverSwitchOne() {
        switchOne?.addTarget(self,
                                action: #selector(VaccineViewController.diseaseSwitchOneDidChange(_:)),
                                for: .touchUpInside)
    }
    private func createObserverSwitchTwo() {
        switchTwo?.addTarget(self,
                                action: #selector(VaccineViewController.diseaseSwitchTwoDidChange(_:)),
                                for: .touchUpInside)
    }
    private func createObserverSwitchThree() {
        switchThree?.addTarget(self,
                                action: #selector(VaccineViewController.diseaseSwitchThreeDidChange(_:)),
                                for: .touchUpInside)
    }
    private func createObserverSwitchFour() {
        switchFour?.addTarget(self,
                                action: #selector(VaccineViewController.diseaseSwitchFourDidChange(_:)),
                                for: .touchUpInside)
    }
    private func createObserverSwitchFive() {
        switchFive?.addTarget(self,
                                action: #selector(VaccineViewController.diseaseSwitchFiveDidChange(_:)),
                                for: .touchUpInside)
    }
    private func createObserverSwitchSix() {
        switchSix?.addTarget(self,
                                action: #selector(VaccineViewController.diseaseSwitchSixDidChange(_:)),
                                for: .touchUpInside)
    }
    private func createObserverSwitchSeven() {
        switchSeven?.addTarget(self,
                                action: #selector(VaccineViewController.diseaseSwitchSevenDidChange(_:)),
                                for: .touchUpInside)
    }
    private func createObserverSwitchEight() {
        switchEight?.addTarget(self,
                                action: #selector(VaccineViewController.diseaseSwitchEightDidChange(_:)),
                                for: .touchUpInside)
    }
    private func formatDate() {
        dateFormatter.locale = localeLanguage
        dateFormatter.dateFormat = "dd MMMM yyyy"
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
            checkChangeDone()
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
