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
        // since IB can't set the status bar and top colour correctly,
        // we do it programmatically here
        navigationBar.barStyle = .black
        navigationBar.barTintColor = UIColor(named: "Accent")
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBar.titleTextAttributes = [.font: UIFont(name: "Montserrat-Bold", size: 20)!]
        
    }
}
