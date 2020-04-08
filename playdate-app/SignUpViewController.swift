//
//  SignUpViewController.swift
//  playdate-app
//
//  Created by Simrat Chandi on 3/19/20.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    @IBOutlet weak var textFieldLoginPasswordRepeat: UITextField!
    @IBOutlet weak var textFieldName: UITextField!
    
    var delegate: UIViewController!
    var theMessage = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
    }
    

    @IBAction func signUpDidTouch(_ sender: Any) {
        guard let email = textFieldLoginEmail.text,
              let password = textFieldLoginPassword.text,
              let repeatPassword = textFieldLoginPasswordRepeat.text,
              email.count > 0,
              password.count > 0,
              repeatPassword.count > 0
        else {
          return
        }
        if(password == repeatPassword) {
            Auth.auth().createUser(withEmail: email, password: password) { user, error in
                if error == nil {
                    Auth.auth().signIn(withEmail: self.textFieldLoginEmail.text!,
                                       password: self.textFieldLoginPassword.text!)
                    if(self.delegate != nil) {
                        let otherVC = self.delegate as! LogIn
                        otherVC.signedIn()
                        self.theMessage = "Return to My Events"
                    }
                    else {
                        self.theMessage = "Return to Log In"
                    }
                    let alert = UIAlertController(
                        title: "Sign Up Successful",
                        message: self.theMessage,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title:"OK",style:.default))
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    let alert = UIAlertController(
                        title: "Error",
                        message: error?.localizedDescription,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title:"OK",style:.default))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        else{
            let alert = UIAlertController(
                title: "Passwords do not match",
                message: "Please make sure passwords are the same",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title:"OK",style:.default))
            self.present(alert, animated: true, completion: nil)
        }
    }
    

}

