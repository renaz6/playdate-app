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
}
