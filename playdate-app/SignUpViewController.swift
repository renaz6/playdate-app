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
    var logInDelegate: UIViewController!
    var settingsDelegate: UIViewController!
    var theMessage = ""
    
    var firestore: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        firestore = Firestore.firestore()
    }
    
    // code to dismiss keyboard when user clicks on background

    func textFieldShouldReturn(textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
                if error == nil, let userInfo = user {
                    // add display name
                    let changeRequest = userInfo.user.createProfileChangeRequest()
                    changeRequest.displayName = self.textFieldName.text
                    changeRequest.commitChanges(completion: { error in
                        print("Error setting your display name: ", error ?? "")
                    })
                    // create entry (saved events) in database
                    let userDocRef = self.firestore.collection("users").document(userInfo.user.uid)
                    userDocRef.setData(["savedEvents": []])
                    
                    Auth.auth().signIn(withEmail: self.textFieldLoginEmail.text!,
                                       password: self.textFieldLoginPassword.text!)
                    if(self.delegate != nil) {
                        let otherVC = self.delegate as! LogIn
                        otherVC.signedIn()
                        self.theMessage = "Return to My Events"
                    }
                    if(self.logInDelegate != nil) {
                        let otherVC = self.logInDelegate as! NotLoggedIn
                        otherVC.isLogged()
                        self.theMessage = "Return to My Events"
                    }
                    if(self.settingsDelegate != nil) {
                        let otherVC = self.settingsDelegate as! LoggedIn
                        self.theMessage = "Return to Settings Page"
                        otherVC.isNowSignedIn()
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

