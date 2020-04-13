//
//  MyEventsViewController.swift
//  playdate-sandbox
//
//  Created by Jared Rankin on 2020-03-03.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import UIKit
import Firebase

protocol LogIn {
    func signedIn()
}

class MyEventsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, LogIn {
    
    @IBOutlet weak var myEventsVCNotSignedIn: UIView!
    @IBOutlet weak var myEventsVCSignedIn: UITableView!
    
    private let eventDetailSegueId = "meToEventDetail"
    private let loginSegueId = "LogInIdentifier"
    private let settingsSegueId = "SettingsIdentifier"
    private let signUpSegueId = "SignUpIdentifier"
    private var userEmail = ""
    private var displayName = ""
    
    private var dataSource: EventDataSource!
    
    private var loggedIn: Bool = false
    private var myEvents: [EventDataType] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = AppDelegate.instance.dataSource
        
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            // Show error message
            print(signOutError)
        }
        
        Auth.auth().addStateDidChangeListener { auth, user in
            self.loggedIn = (user != nil)

            self.myEventsVCNotSignedIn.isHidden = self.loggedIn
            self.myEventsVCSignedIn.isHidden = !self.loggedIn
            if(user != nil) {
                self.userEmail = (user?.email)!
                self.displayName = user?.displayName ?? ""
                
                // load favourite events if we're logged in
                self.dataSource.starredEvents { events in
                    self.myEvents = events
                    self.myEventsVCSignedIn.reloadData()
                }
            }
        }
        
// TODO: if a account is deleted Listener still finds an User
//        if(loggedIn == false) {
//            self.myEventsVCNotSignedIn.isHidden = self.loggedIn
//            self.myEventsVCSignedIn.isHidden = !self.loggedIn
//        }
//        else {
//            self.myEventsVCNotSignedIn.isHidden = self.loggedIn
//            self.myEventsVCSignedIn.isHidden = !self.loggedIn
//        }
//
//
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myEvents.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let eventData = myEvents[indexPath.row] // TODO
        
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
        if let cell = reusableCell as? EventTableViewCell {
            cell.index = indexPath.row
            cell.eventId = eventData.id
            cell.eventImageView.image = UIImage(systemName: eventData.imageId)
            cell.eventTitleLabel.text = eventData.title
            cell.eventVenueLabel.text = eventData.venueName
            cell.setDate(eventData.datesStart?.dateValue())
            return cell
        } else {
            return reusableCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == eventDetailSegueId,
            let dest = segue.destination as? EventDetailViewController,
            let cell = sender as? EventTableViewCell {

            dest.event = myEvents[cell.index]
        } else if segue.identifier == loginSegueId {
            let destination = segue.destination as! LoginViewController
            destination.delegate = self
        } else if segue.identifier == settingsSegueId {
            let destination = segue.destination as! SettingsViewController
            destination.delegate = self
            destination.signedIn = loggedIn
            destination.userEmail = self.userEmail
            destination.displayName = self.displayName
        } else if segue.identifier == signUpSegueId {
            let destination = segue.destination as! SignUpViewController
            destination.delegate = self
        }
    }
    
    private func describeDate(_ date: Date?) -> String {
        if let date = date {
            let dateFormat = DateFormatter()
            let timeFormat = DateFormatter()
            dateFormat.dateStyle = .medium
            timeFormat.timeStyle = .short
            dateFormat.timeZone = .autoupdatingCurrent
            timeFormat.timeZone = .autoupdatingCurrent
            
            return dateFormat.string(from: date) + ", " + timeFormat.string(from: date)
        } else {
            return ""
        }
    }
    
    func signedIn() {
        loggedIn = true
        myEventsVCNotSignedIn.isHidden = true
        myEventsVCSignedIn.isHidden = false
    }
}
