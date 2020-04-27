//
//  ChangePasswordViewController.swift
//  playdate-app
//
//  Created by Simrat Chandi on 4/13/20.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import UIKit
import Firebase

class ChangePasswordViewController: UIViewController {

    var delegate: UIViewController!
    var email:String!
    @IBOutlet weak var currentPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var repeatPassword: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // code to dismiss keyboard when user clicks on background

    func textFieldShouldReturn(textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func changePasswordBtnPressed(_ sender: Any) {
//        let alert = UIAlertController(
//          title: "Change Password",
//          message: "Changing your password is not yet implemented.",
//          preferredStyle: .alert)
//
//        alert.addAction(UIAlertAction(title:"OK",style:.default))
//        self.present(alert, animated: true, completion: nil)
//        if(email != "" && currentPassword.text != "" && newPassword.text != "" && repeatPassword.text != "") {
//            let emailCred = EmailAuthProvider.credential(withEmail: email, password: currentPassword.text!)
//            Auth.auth().currentUser?.reauthenticate(with: emailCred, completion: { result, err in
//                    if err == nil{
//                        print("reAuth failed with error: \(err!)")
//                    }
//                    else{ // User re-authenticated.
//                        if(self.newPassword.text == self.repeatPassword.text) {
//                            Auth.auth().currentUser?.updatePassword(to: self.newPassword.text!) { (error) in
//                              // ...
//                            }
//                        }
//                    }
//            })
//        }
//        else {
//            
//        }
    }
}
