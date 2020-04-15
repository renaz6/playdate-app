//
//  SettingsViewController.swift
//  playdate-app
//
//  Created by Jared Rankin on 2020-02-28.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import UIKit
import CoreData
import Firebase

protocol LoggedIn {
    func isNowSignedIn(withDisplayName: String?)
}

class SettingsViewController: UITableViewController, LoggedIn {
    
    var signedIn = true
    let sectionTitles = ["User Account", "Miscellaneous"]
    var delegate: UIViewController!
    var settings:[NSManagedObject] = []
    var userEmail: String = "user@example.com"
    var displayName: String = "User Name"
    let changeDetailVC: String = "changeDetailSegue"
    let changePasswordVC: String = "ChangePasswordSegue"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        settings = fetchData()
        if(settings.count == 0) {
            createSettingsEntity()
        }
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if(user != nil) {
                self.userEmail = user!.email!
                if let name = user?.displayName {
                    self.displayName = name
                }
            }
            
        }
        
        
    }

    
    func isNowSignedIn(withDisplayName displayName: String?) {
        signedIn = true
        if let name = displayName {
            self.displayName = name
        }
        if (delegate != nil) {
            let otherVC = self.delegate as! LogIn
            otherVC.signedIn(withDisplayName: displayName)
        }
        tableView.reloadData()
    }
    
    func fetchData() -> [NSManagedObject]{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Settings")
        var fetchedSettings:[NSManagedObject]? = nil
        
        do {
            try fetchedSettings = context.fetch(request) as? [NSManagedObject]
        } catch {
            // If an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        return (fetchedSettings)!
    }
    
    func createSettingsEntity() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let setting = NSEntityDescription.insertNewObject(
            forEntityName: "Settings", into: context)

        
        // Set the attribute values
        setting.setValue(false, forKey: "isDarkMode")
        setting.setValue(false, forKey: "isNotifications")
        
        // Commit the changes
        do {
            try context.save()
        } catch {
            // If an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        //update the local copy
        settings.append(setting)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.reuseIdentifier == "signOutCell" {
            // sign user out
            do {
                try Auth.auth().signOut()
            } catch {
                print(error)
            }
            navigationController?.popViewController(animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
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
            return tableView.dequeueReusableCell(withIdentifier: "signOutCell", for: indexPath)
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
        if let customCell = cell as? SettingsTableViewCellWithSwitch {
            switch indexPath.row {
            case 0:
                customCell.titleLabel.text = "Dark Mode"
                customCell.settingSwitch.addTarget(self,action: #selector(switchValueDidChange(_:)), for: .valueChanged)
                
                let isDarkMode = (settings[0].value(forKeyPath: "isDarkMode") as! Bool)
                customCell.settingSwitch.setOn(isDarkMode, animated: false)
            case 1:
                customCell.titleLabel.text = "Send Push Notifications"
            default:
                customCell.titleLabel.text = "Something else \(indexPath.row)"
            }
            return customCell
        }
        return cell
    }
    
    private func userInfoCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userInfoCell", for: indexPath)
        if let customCell = cell as? SettingsUserInfoTableViewCell {
            customCell.profilePicView.image = UIImage(named: "Avatar")
            customCell.displayNameLabel.text = displayName
            customCell.emailLabel.text = userEmail
            
            return customCell
        }
        return cell
    }
    
    // code to dismiss keyboard when user clicks on background

    func textFieldShouldReturn(textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SettingstoSignInSegue" {
            let destination = segue.destination as! LoginViewController
            destination.settingsDelegate = self
        }
        if segue.identifier == "SignUpFromSettings" {
            let destination = segue.destination as! SignUpViewController
            destination.settingsDelegate = self
        }
        if segue.identifier == changeDetailVC {
            let destination = segue.destination as! ChangeDetailsViewController
            destination.delegate = self
            destination.displayName = self.displayName
            destination.userEmail = self.userEmail
        }
        if segue.identifier == changePasswordVC {
            let destination = segue.destination as! ChangePasswordViewController
            destination.delegate = self
        }
    }
    
    
    
    @objc func switchValueDidChange(_ sender: UISwitch!) {
        if (sender.isOn == true){
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .dark
            }
        }
        else{
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .light
            }
        }
        updateDarkModeSettings(darkMode: sender.isOn)
    }

    func updateDarkModeSettings(darkMode: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
               
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Settings")
               
        
        var fetchedResults:[NSManagedObject]? = nil
        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
            if(fetchedResults!.count != 0) {
                let setting = fetchedResults![0]
                setting.setValue(darkMode, forKey: "isDarkMode")
            }
            try context.save()
        } catch {
            // If an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        settings = fetchData()
    }
}
