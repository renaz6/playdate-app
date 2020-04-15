//
//  TabBarViewController.swift
//  playdate-app
//
//  Created by Serena  Zamarripa on 4/15/20.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController,
UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController,
                          didSelect viewController: UIViewController) {
            if let vc = viewController as? UINavigationController {
                vc.popToRootViewController(animated: false);
            }
    }
    

}
