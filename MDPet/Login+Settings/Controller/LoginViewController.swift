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
//    private var activeField: UITextField?

    // MARK: Outlets
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!

    override var preferredStatusBarStyle: UIStatusBarStyle {
      return .lightContent
    }

    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
      super.viewDidLoad()

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
            let alert = UIAlertController(title: "Sign In Failed",
                                          message: error.localizedDescription,
                                          preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default))

            self.present(alert, animated: true, completion: nil)
          }
        }
    }
    private func handleRegister() {
        let alert = UIAlertController(title: "Register",
                                      message: "Register",
                                      preferredStyle: .alert)

        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            let emailField = alert.textFields![0]
            let passwordField = alert.textFields![1]
            Auth.auth().createUser(withEmail: emailField.text!,
                                   password: passwordField.text!) { _, error in
                                    if error == nil {
                                        Auth.auth().signIn(withEmail: self.textFieldLoginEmail.text!,
                                                           password: self.textFieldLoginPassword.text!)
                                    } else {
                                        let alert = UIAlertController(title: "Sign In Failed",
                                                                      message: error?.localizedDescription,
                                                                      preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                                        self.present(alert, animated: true, completion: nil)
                                        return
                                    }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)

        alert.addTextField { textEmail in
          textEmail.placeholder = "Enter your email"
        }

        alert.addTextField { textPassword in
          textPassword.isSecureTextEntry = true
          textPassword.placeholder = "Enter your password"
        }

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

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
