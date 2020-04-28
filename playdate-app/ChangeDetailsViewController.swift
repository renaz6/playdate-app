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
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailLabel.text = userEmail
        nameTextField.text = displayName
    }
    
    // code to dismiss keyboard when user clicks on background

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        saveButtonPressed(textField)
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if nameTextField.text != "" {
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = nameTextField.text
            changeRequest?.commitChanges { (error) in
            if error != nil {
                let alert = UIAlertController(
                    title: "Changing Name error",
                    message: error?.localizedDescription,
                    preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title:"OK",style:.default))
                self.present(alert, animated: true, completion: nil)
                return
            } else {
                let alert = UIAlertController(
                    title: "Succesfully Changed Account Details",
                    message: "Next time PlayDate is opened details will be changed",
                    preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title:"OK",style:.default))
                self.present(alert, animated: true, completion: nil)
            }
            }
        }
    }
}
