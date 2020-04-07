//
//  MyEventsViewController.swift
//  playdate-sandbox
//
//  Created by Jared Rankin on 2020-03-03.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import UIKit

protocol LogIn {
    func signedIn()
}

class MyEventsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, LogIn {
    

    @IBOutlet weak var myEventsVCNotSignedIn: UIView!
    @IBOutlet weak var myEventsVCSignedIn: UITableView!
    private let eventDetailSegueId = "meToEventDetail"
    private let loginSegueId = "LogInIdentifier"
    
    private var dataSource: EventDataSource!
    
    private var loggedIn: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = MockDataSource()
        
        if(loggedIn == false) {
            myEventsVCNotSignedIn.isHidden = false
            myEventsVCSignedIn.isHidden = true
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.homePageEvents().count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let eventData = dataSource.homePageEvents()[indexPath.row] // TODO
        
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
        if let cell = reusableCell as? EventTableViewCell {
            cell.eventImageView.image = UIImage(systemName: eventData["imageId"] as! String)
            cell.eventTitleLabel.text = eventData["title"] as? String
            cell.eventVenueLabel.text = eventData["venue"] as? String
            cell.setDate(eventData["startDate"] as? Date)
            return cell
        } else {
            return reusableCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: eventDetailSegueId, sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == eventDetailSegueId,
//            let dest = segue.destination as? EventDetailViewController,
//            let ip = sender as? IndexPath {
//
//            dest.event = dataSource.homePageEvents()[ip.row]
//        }
        if segue.identifier == loginSegueId {
            let destination = segue.destination as! LoginViewController
            destination.delegate = self
        }
    }
    
    private func describeDate(_ date: Date?) -> String {
        if let date = date {
            let dateFormat = DateFormatter()
            let timeFormat = DateFormatter()
            dateFormat.dateStyle = .medium
            timeFormat.timeStyle = .short
            
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
