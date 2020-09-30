//
//  LoginViewController.swift
//  MDPet
//
//  Created by Philippe on 19/02/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import UIKit
import CloudKit

class LoginViewController: UIViewController {

    @IBOutlet weak var nameUserLabel: UILabel!
    @IBOutlet weak var iCloudAccountLabel: UILabel!

    @IBAction func connexion(_ sender: Any) {
        UIApplication.shared.open(URL(string: "App-Prefs:root=Settings")!, options: [:], completionHandler: nil)
    }

    var userRecord: CKRecord?

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(startDiscoveryProcess),
                                               name: Notification.Name.CKAccountChanged, object: nil)
        startDiscoveryProcess()
    }
    @objc private func startDiscoveryProcess() {

        container.accountStatus { status, error in
            DispatchQueue.main.async {
                if let error = error {
                    let alert = UIAlertController(title: "Account Error",
                                                  message: "Unable to determine iCloud account status.\n\(error.localizedDescription)",
                                                  preferredStyle: .alert)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    switch status {
                    case .available:
                        self.fetchUserRecordIdentifier()
                    case .couldNotDetermine, .noAccount, .restricted:
                        self.nameUserLabel.text = ""
                        self.iCloudAccountLabel.text = "Non connecté à iCloud"
                    @unknown default:
                        fatalError()
                    }
                }
            }
        }
    }
    private func fetchUserRecordIdentifier() {
        container.fetchUserRecordID { recordID, error in
            guard let recordID = recordID, error == nil else {
                // error handling magic
                return
            }

            DispatchQueue.main.async {
                print("Got user record ID \(recordID.recordName). Fetching info...")
                self.fetchUserRecord(with: recordID)
                self.discoverIdentity(for: recordID)
//                self.discoverFriends()
            }
        }
    }
    private func fetchUserRecord(with recordID: CKRecord.ID) {
        container.publicCloudDatabase.fetch(withRecordID: recordID) { record, error in
            guard let record = record, error == nil else {
                // show off your error handling skills
                return
            }

            print("The user record is: \(record)")

            DispatchQueue.main.async {
                self.userRecord = record
            }
        }
    }

    private func discoverIdentity(for recordID: CKRecord.ID) {
        container.requestApplicationPermission(.userDiscoverability) { status, error in
            guard status == .granted, error == nil else {
                // error handling voodoo
                DispatchQueue.main.async {
                    self.nameUserLabel.text = "NOT AUTHORIZED"
                }
                return
            }

            self.container.discoverUserIdentity(withUserRecordID: recordID) { identity, error in
                defer {
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                }

                guard let components = identity?.nameComponents, error == nil else {
                    // more error handling magic
                    return
                }

                DispatchQueue.main.async {
                    let formatter = PersonNameComponentsFormatter()
                    self.nameUserLabel.text = formatter.string(from: components)
                }
            }
        }
    }
}
