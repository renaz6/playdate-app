//
//  LoginViewController.swift
//  playdate-app
//
//  Created by Simrat Chandi on 3/18/20.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import UIKit
import Firebase

protocol NotLoggedIn {
    func isLogged(withDisplayName: String?)
}

class LoginViewController: UIViewController, NotLoggedIn {

    @IBOutlet weak var textFieldLoginEmail: UITextField!
    
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    
    var delegate: UIViewController!
    var settingsDelegate: UIViewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(settingsDelegate != nil) {
            signUpLabel.isHidden = true
            signUpButton.isHidden = true
        }
        else {
            signUpLabel.isHidden = false
            signUpButton.isHidden = false
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
          else {
                var message = "Return to MyEvents Page"
                print("Login In Successful!")
                if(self.delegate != nil) {
                    let otherVC = self.delegate as! LogIn
                    otherVC.signedIn(withDisplayName: nil)
                }
                else if(self.settingsDelegate != nil){
                    let otherVC = self.settingsDelegate as! LoggedIn
                    message = "Return to Settings Page"
                    otherVC.isNowSignedIn(withDisplayName: nil)
                }
                //self.performSegue(withIdentifier: "LoggedIn", sender: nil)
                let alert = UIAlertController(
                  title: "Sign in Successful",
                  message: message,
                  preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title:"OK",style:.default))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SignUpIdentifier" {
            let destination = segue.destination as! SignUpViewController
            destination.logInDelegate = self
        }
        if let navigator = navigationController {
            navigator.popViewController(animated: true)
        }
    }
    
    func isLogged(withDisplayName displayName: String?) {
        if (delegate != nil) {
            let otherVC = self.delegate as! LogIn
            otherVC.signedIn(withDisplayName: displayName)
        }
    }
    
    // code to dismiss keyboard when user clicks on background

    func textFieldShouldReturn(textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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

