//
//  StyledNavigationController.swift
//  playdate-app
//
//  Created by Jared Rankin on 2020-04-01.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import UIKit

class StyledNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationBar.barStyle = .black
        navigationBar.barTintColor = UIColor(named: "Accent")
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    

    // code to dismiss keyboard when user clicks on background

      func textFieldShouldReturn(textField:UITextField) -> Bool {
          textField.resignFirstResponder()
          return true
      }
      
      override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
          self.view.endEditing(true)
      }
}
