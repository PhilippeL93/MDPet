//
//  LoginViewController.swift
//  MDPet
//
//  Created by Philippe on 19/02/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseCore

class LoginViewController: UIViewController {

    // MARK: Constants
    var userUid: UserUid!
    var authenticationError: AuthenticationError?
    var signedInUser: User?
    private var authenticationGateway: AuthenticationGateway!
    private var auth: Auth = {
        print("=================== LoginViewController private var auth")
        print("================= LoginViewController \(FirebaseApp.app()) ")
        if FirebaseApp.app() == nil {
            print("================ LoginViewController FirebaseApp.app() == nil")
            FirebaseApp.configure()
        }
        return Auth.auth()
    }()

    // MARK: Outlets
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    @IBOutlet weak var missingPasswordButton: UIButton!

    override var preferredStatusBarStyle: UIStatusBarStyle {
      return .lightContent
    }

    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        authenticationGateway = AuthenticationGatewayFirebase(auth: auth)
        missingPasswordButton.underlineMyText()
//        Auth.auth().addStateDidChangeListener { _, user in
//            if user != nil {
//                self.performSegue(withIdentifier: self.loginToList, sender: nil)
//                self.textFieldLoginEmail.text = nil
//                self.textFieldLoginPassword.text = nil
//                UserUid.uid = user!.uid
//            }
//        }
    }

    @IBAction func loginDidTouch(_ sender: Any) {
        handleLogin()
    }

    @IBAction func signUpDidTouch(_ sender: Any) {
        handleRegister()
    }

    @IBAction func missingPassword(_ sender: Any) {
        handleMissingPassword()
    }

    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        textFieldLoginEmail.resignFirstResponder()
        textFieldLoginPassword.resignFirstResponder()
    }

    private func handleLogin() {
        guard
            let email = textFieldLoginEmail.text,
            let password = textFieldLoginPassword.text,
            email.count > 0,
            password.count > 0
            else {
                return
        }
        let userParams = RegisterUserBasicParams(email: email, password: password)
        authenticationGateway.connect(userParams: userParams) { result in
            switch result {
            case let .success(user):
                self.signedInUser = user
            case let .failure(error):
                self.authenticationError = error
                self.presentAlert(error: self.authenticationError!)
            }
        }
    }

    private func generateUserEntity(identifier: String, userParams: RegisterUserBasicParams) -> User {
        return UserEntity(uid: identifier, email: userParams.email)
    }

    private func handleRegister() {
        let alert = UIAlertController(title: "Enregistrement",
                                      message: "S'enregistrer",
                                      preferredStyle: .alert)

        let saveAction = UIAlertAction(title: "Sauvegarder", style: .default) { _ in
            let emailField = alert.textFields![0]
            let passwordField = alert.textFields![1]
            let userParams = RegisterUserBasicParams(email: emailField.text!, password: passwordField.text!)
            self.authenticationGateway.register(userParams: userParams) { result in
                switch result {
                case let .success(user):
                    self.signedInUser = user
                    self.authenticationGateway.connect(userParams: userParams) { result in
                        switch result {
                        case let .success(user):
                            self.signedInUser = user
                        case let .failure(error):
                            self.authenticationError = error
                            self.presentAlert(error: self.authenticationError!)
                        }
                    }
                case let .failure(error):
                    self.authenticationError = error
                    self.presentAlert(error: self.authenticationError!)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Annuler",
                                         style: .cancel)

        alert.addTextField { textEmail in
            textEmail.placeholder = "Entrer votre email"
        }

        alert.addTextField { textPassword in
            textPassword.isSecureTextEntry = true
            textPassword.placeholder = "Entrer votre Mot de Passe"
        }

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    private func handleMissingPassword() {
        guard
            let email = textFieldLoginEmail.text,
            email.count > 0
            else {
                return
        }
        let userParams = RegisterUserBasicParams(email: email, password: "")
        authenticationGateway.resetPassword(userParams: userParams) { result in
            switch result {
            case let .success(user):
                self.signedInUser = user
            case let .failure(error):
                self.authenticationError = error
                self.presentAlert(error: self.authenticationError!)
            }
        }
    }
    private func presentAlert(error: AuthenticationError) {
        var message = ""
        switch error {
        case .invalidName:
            message = "Nom inconnu"
        case .invalidPassword:
            message = "Mot de passe non robuste"
        case .userDisabled:
            message = "Utilisateur désactivé"
        case .emailAlreadyInUse:
            message = "Utilisateur déjà existant"
        case .invalidEmail:
            message = "Email invalide"
        case .wrongPassword:
            message = "Mot de passe incorrect"
        case .userNotFound:
            message = "Utilisateur inconnu"
        case .accountExistsWithDifferentCredential:
            message = "Compte déjà existant"
        case .networkError:
            message = "Pas de connexion"
        case .credentialAlreadyInUse:
            message = "Compte déjà utilisé"
        case .unknown:
            message = "Erreur inconnu"
        }
        let alert = UIAlertController(title: "Connexion",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
}

extension LoginViewController: UITextFieldDelegate {

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == textFieldLoginEmail {
      textFieldLoginPassword.becomeFirstResponder()
    }
    if textField == textFieldLoginPassword {
      textField.resignFirstResponder()
    }
    return true
  }
}

extension UIButton {
    func underlineMyText() {
        guard let text = self.titleLabel?.text else { return }

        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle,
                                      value: NSUnderlineStyle.single.rawValue,
                                      range: NSRange(location: 0, length: text.count))

        self.setAttributedTitle(attributedString, for: .normal)
    }
}
