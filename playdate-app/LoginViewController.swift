//
//  LoginViewController.swift
//  playdate-app
//
//  Created by Simrat Chandi on 3/18/20.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var textFieldLoginEmail: UITextField!
    
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Auth.auth().addStateDidChangeListener() {
          auth, user in
          
          if user != nil {
            self.performSegue(withIdentifier: "myEventsIdentifier", sender: nil)
            self.textFieldLoginEmail.text = nil
            self.textFieldLoginPassword.text = nil
          }
        }
    }
    

    @IBAction func loginDidTouch(_ sender: Any) {
        guard let email = textFieldLoginEmail.text,
              let password = textFieldLoginPassword.text,
              email.count > 0,
              password.count > 0
        else {
          return
        }

        Auth.auth().signIn(withEmail: email, password: password) {
          user, error in
          if let error = error, user == nil {
            let alert = UIAlertController(
              title: "Sign in failed",
              message: error.localizedDescription,
              preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title:"OK",style:.default))
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

