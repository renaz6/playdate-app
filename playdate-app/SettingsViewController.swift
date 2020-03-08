//
//  SettingsViewController.swift
//  playdate-sandbox
//
//  Created by Jared Rankin on 2020-02-28.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    let signedIn = true
    let sectionTitles = ["User Account", "Miscellaneous"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 && signedIn {
            return 168.0
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return signedIn ? 4 : 2
        case 1:
            return 2
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return signedIn ? cellInUserAccountSectionSignedIn(for: indexPath) : cellInUserAccountSectionSignedOut(for: indexPath)
        case 1:
            return cellInMiscSection(for: indexPath)
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            cell.textLabel?.text = "Don't know (section \(indexPath.section), row \(indexPath.row))"
            return cell
        }
    }
    
    private func cellInUserAccountSectionSignedIn(for indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return userInfoCell(for: indexPath)
        case 1:
            return tableView.dequeueReusableCell(withIdentifier: "changeDetailsCell", for: indexPath)
        case 2:
            return tableView.dequeueReusableCell(withIdentifier: "changePasswordCell", for: indexPath)
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCellNoDisclosure", for: indexPath)
            cell.textLabel?.text = "Sign Out"
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            cell.textLabel?.text = "Something else"
            return cell
        }
    }
    
    private func cellInUserAccountSectionSignedOut(for indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return tableView.dequeueReusableCell(withIdentifier: "signInCell", for: indexPath)
        case 1:
            return tableView.dequeueReusableCell(withIdentifier: "signUpCell", for: indexPath)
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            cell.textLabel?.text = "Something else"
            return cell
        }
    }
    
    private func cellInMiscSection(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath)
        switch indexPath.row {
        case 0:
            (cell.contentView.viewWithTag(1) as? UILabel)?.text = "Dark Mode"
        case 1:
            (cell.contentView.viewWithTag(1) as? UILabel)?.text = "Send Push Notifications"
        default:
            (cell.contentView.viewWithTag(1) as? UILabel)?.text = "Something else \(indexPath.row)"
        }
        return cell
    }
    
    private func userInfoCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userInfoCell", for: indexPath)
        
        (cell.contentView.viewWithTag(1) as? UIImageView)?.image = UIImage(systemName: "person.fill")
        (cell.contentView.viewWithTag(2) as? UILabel)?.text = "User Name"
        (cell.contentView.viewWithTag(3) as? UILabel)?.text = "user@example.com"
        
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
