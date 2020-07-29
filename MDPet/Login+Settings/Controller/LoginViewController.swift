//
//  LoginViewController.swift
//  MDPet
//
//  Created by Philippe on 19/02/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    // MARK: Constants
    let loginToList = "LoginToList"
    var userUid: UserUid!

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
        missingPasswordButton.underlineMyText()
        Auth.auth().addStateDidChangeListener { _, user in
            if user != nil {
                self.performSegue(withIdentifier: self.loginToList, sender: nil)
                self.textFieldLoginEmail.text = nil
                self.textFieldLoginPassword.text = nil
                UserUid.uid = user!.uid
            }
        }
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
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
          if let error = error, user == nil {
            let alert = UIAlertController(title: "Connexion a échoué",
                                          message: error.localizedDescription,
                                          preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default))

            self.present(alert, animated: true, completion: nil)
          }
        }
    }
    private func handleRegister() {
        let alert = UIAlertController(title: "Enregistrement",
                                      message: "S'enregistrer",
                                      preferredStyle: .alert)

        let saveAction = UIAlertAction(title: "Sauvegarder", style: .default) { _ in
            let emailField = alert.textFields![0]
            let passwordField = alert.textFields![1]
            Auth.auth().createUser(withEmail: emailField.text!,
                                   password: passwordField.text!) { _, error in
                                    if error == nil {
                                        Auth.auth().signIn(withEmail: self.textFieldLoginEmail.text!,
                                                           password: self.textFieldLoginPassword.text!)
                                    } else {
                                        let alert = UIAlertController(title: "Connexion a échoué",
                                                                      message: error?.localizedDescription,
                                                                      preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                                        self.present(alert, animated: true, completion: nil)
                                        return
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
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                let alert = UIAlertController(title: "Email inconnu",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "OK", style: .default))

                self.present(alert, animated: true, completion: nil)
            }
        }
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
