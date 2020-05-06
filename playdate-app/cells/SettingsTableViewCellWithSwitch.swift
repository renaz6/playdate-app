//
//  SettingsTableViewCellWithSwitch.swift
//  playdate-app
//
//  Created by Jared Rankin on 2020-04-15.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import UIKit

class SettingsTableViewCellWithSwitch: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var settingSwitch: UISwitch!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
        
        titleLabel.font = UIFont(name: "Gibson-Regular", size: 20)
        
    }
}
