//
//  ChangeDetailsViewController.swift
//  playdate-app
//
//  Created by Simrat Chandi on 4/13/20.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import UIKit
import Firebase

class ChangeDetailsViewController: UIViewController {

    var delegate: UIViewController!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userEmailTextField: UITextField!
    var userEmail: String = ""
    var displayName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        userEmailTextField.text = userEmail
        userNameTextField.text = displayName
    }
    
    // code to dismiss keyboard when user clicks on background

    func textFieldShouldReturn(textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
              if(userNameTextField.text != nil || userNameTextField.text != ""){
                  let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                  changeRequest?.displayName = userNameTextField.text
                  changeRequest?.commitChanges { (error) in
                      if(error != nil) {
                          let alert = UIAlertController(
                            title: "changing Name error",
                            message: error?.localizedDescription,
                            preferredStyle: .alert)
                          
                          alert.addAction(UIAlertAction(title:"OK",style:.default))
                          self.present(alert, animated: true, completion: nil)
                          return
                      }
                      else {
                          if(self.userEmailTextField.text != nil || self.userEmailTextField.text != "") {
                              let alert = UIAlertController(
                                title: "Change Details",
                                message: "Changing your email address is not yet implemented.",
                                preferredStyle: .alert)
                              
                              alert.addAction(UIAlertAction(title:"OK",style:.default))
                              self.present(alert, animated: true, completion: nil)
                              return;
                              
                              //self.reautheticateUser()
                              Auth.auth().currentUser?.updateEmail(to: self.userEmailTextField.text!) { (error) in
                                if(error != nil) {
                                  print("ERROR!!!! \(error?.localizedDescription ?? "")")
                                    let alert = UIAlertController(
                                      title: "changing email error",
                                      message: error?.localizedDescription,
                                      preferredStyle: .alert)
                                    
                                    alert.addAction(UIAlertAction(title:"OK",style:.default))
                                    self.present(alert, animated: true, completion: nil)
                                    return
                                }
                                else {
                                       let alert = UIAlertController(
                                       title: "Succesfully Changed Account Details",
                                       message: "next time PlayDate is opened Details will be changed",
                                       preferredStyle: .alert)
                                                 
                                       alert.addAction(UIAlertAction(title:"OK",style:.default))
                                       self.present(alert, animated: true, completion: nil)
                                 }
                              }
                              
                          }
                      }
                  }
        }
    }

    func reautheticateUser() {
        
        var email: String = ""
        var passwordText: String = ""

        // Prompt the user to re-provide their sign-in credentials
        let alert = UIAlertController(title: "Register",
                                      message: "Register",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            // 1
            let emailField = alert.textFields![0]
            let passwordField = alert.textFields![1]
            
            email = emailField.text!
            passwordText = passwordField.text!
    
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
        
        let emailCred = EmailAuthProvider.credential(withEmail: email, password: passwordText)
    
        Auth.auth().currentUser?.reauthenticate(with: emailCred, completion: { (result, err) in
            if err == nil{
                print("reAuth failed with error: \(err!)")
            }else{
                print("reAuth Success!!")
                
            }
        })
        
    }
}
