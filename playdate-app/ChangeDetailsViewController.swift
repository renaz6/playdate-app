//
//  ChangeDetailsViewController.swift
//  playdate-app
//
//  Created by Simrat Chandi on 4/13/20.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import UIKit
import Firebase

class ChangeDetailsViewController: UIViewController, UITextFieldDelegate {

    var delegate: UIViewController!
    var userEmail: String = ""
    var displayName: String = ""
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nameTextField.text = displayName
        
        emailTitleLabel.font = UIFont(name: "Gibson-Regular", size: 18)
        nameTextField.font = UIFont(name: "Gibson-Regular", size: 18)
        nameTextField.setPaddingPoints(12)
    }
    
    // perform the action (complete details change) when user presses return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        saveButtonPressed(textField)
        return true
    }
    
    // code to dismiss keyboard when user clicks on background
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if nameTextField.text != "" {
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = nameTextField.text
            changeRequest?.commitChanges { error in
                if error != nil {
                    let alert = UIAlertController(
                        title: "Changing Name error",
                        message: error?.localizedDescription,
                        preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                    return
                } else {
                    let alert = UIAlertController(
                        title: "Succesfully Changed Account Details",
                        message: "Next time PlayDate is opened details will be changed",
                        preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}
