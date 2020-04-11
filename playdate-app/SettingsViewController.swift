//
//  SettingsViewController.swift
//  playdate-sandbox
//
//  Created by Jared Rankin on 2020-02-28.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import UIKit
import CoreData
import Firebase

protocol LoggedIn {
    func isNowSignedIn()
}

class SettingsViewController: UITableViewController, LoggedIn {
    
    var signedIn = true
    let sectionTitles = ["User Account", "Miscellaneous"]
    var delegate: UIViewController!
    var settings:[NSManagedObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        settings = fetchData()
        if(settings.count == 0) {
            createSettingsEntity()
        }
    }
    
    func isNowSignedIn() {
        signedIn = true
        if (delegate != nil) {
            let otherVC = self.delegate as! LogIn
            otherVC.signedIn()
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
        switch indexPath.row {
        case 0:
            (cell.contentView.viewWithTag(1) as? UILabel)?.text = "Dark Mode"
            (cell.contentView.viewWithTag(2) as? UISwitch)?.addTarget(self,action: #selector(switchValueDidChange(_:)), for: .valueChanged)
            let isDarkMode = (settings[0].value(forKeyPath: "isDarkMode") as! Bool)
            (cell.contentView.viewWithTag(2) as? UISwitch)?.setOn(isDarkMode, animated: false)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SettingstoSignInSegue" {
            let destination = segue.destination as! LoginViewController
            destination.settingsDelegate = self
        }
    }
    
    
    
    @objc func switchValueDidChange(_ sender: UISwitch!) {
        if (sender.isOn == true){
            //inDarkMode = true
            //print("on!!!")
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .dark
            }
        }
        else{
            //inDarkMode = false
            //print("off!!!!!!!")
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
