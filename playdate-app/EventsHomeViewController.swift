//
//  EventsHomeViewController.swift
//  playdate-app
//
//  Created by Jared Rankin on 2020-03-18.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import UserNotifications

class EventsHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UNUserNotificationCenterDelegate  {
    
    private let eventDetailSegueId = "homeToEventDetail"
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segCtrl: UISegmentedControl!
    
    private var dataSource: EventDataSource!
    private var events: [EventDataType] = []
    private var theatreEvents: [EventDataType] = []
    private var isNotifications: Bool = true
    private let seconds:TimeInterval = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = AppDelegate.instance.dataSource
        fetchSettings()
        
        dataSource.homePageEvents { events in
            self.events = events
            self.tableView.reloadData()
        }
        UNUserNotificationCenter.current().delegate = self
        
    }
    @IBAction func onSegmentChanged(_ sender: Any) {
        
        switch segCtrl.selectedSegmentIndex {
        case 0:
                dataSource.homePageEvents { events in
                    self.events = events
                    self.tableView.reloadData()
                }
        case 1:
                dataSource.eventsWithCategory("Theatre") { events in
                    self.events = events
                    self.tableView.reloadData()
                }
        case 2:
                dataSource.eventsWithCategory("Music") { events in
                    self.events = events
                    self.tableView.reloadData()
                }
        case 3:
                dataSource.eventsWithCategory("Comedy") { events in
                    self.events = events
                    self.tableView.reloadData()
                }
        case 4:
                dataSource.eventsWithCategory("Fine Art") { events in
                    self.events = events
                    self.tableView.reloadData()
                }
        case 5:
                dataSource.eventsWithCategory("miscellaneous") { events in
                    self.events = events
                    self.tableView.reloadData()
                }
        default:
            dataSource.homePageEvents { events in
                self.events = events
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sendNotification()
        return events.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let eventData = events[indexPath.row]
        
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
        if let cell = reusableCell as? EventTableViewCell {
            cell.index = indexPath.row
            cell.eventId = eventData.id
            cell.eventImageView.image = UIImage(named: eventData.imageId)
            cell.eventTitleLabel.text = eventData.title
            cell.eventVenueLabel.text = eventData.venueName
            cell.eventDatesLabel.text = eventData.startDateTimeDescription
            return cell
        } else {
            return reusableCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // so the row doesn't stay selected
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == eventDetailSegueId,
            let dest = segue.destination as? EventDetailViewController,
            let cell = sender as? EventTableViewCell {
            dest.event = events[cell.index]
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
    
    func fetchSettings() {
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
        
        if (fetchedSettings!.count != 0) {
            if (fetchedSettings![0].value(forKeyPath: "isDarkMode") as! Bool) {
                UIApplication.shared.windows.forEach { window in
                    window.overrideUserInterfaceStyle = .dark
                }
            }
            else {
                UIApplication.shared.windows.forEach { window in
                    window.overrideUserInterfaceStyle = .light
                }
            }
            isNotifications = fetchedSettings![0].value(forKeyPath: "isNotifications") as! Bool
        }
    }
    
    func sendNotification () {
        if(isNotifications && events.count > 0) {
               // create an object that holds the data for our notification
            let randomEvent = Int.random(in: 0 ..< events.count)
            
            let notificationTitle = "Check out this show"
            let eventData = events[randomEvent]
            let notification = UNMutableNotificationContent()
            notification.title = notificationTitle
            notification.subtitle = eventData.title
            notification.body = eventData.venueName
            //notification.badge = 17
               
            // set up the notification to trigger after a delay of "seconds"
            let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
               
            // set up a request to tell iOS to submit the notification with that trigger
            let request = UNNotificationRequest(identifier: notificationTitle,
                                                   content: notification,
                                                   trigger: notificationTrigger)
               
               
               // submit the request to iOS
            UNUserNotificationCenter.current().add(request) { (error) in
                print("Request error: ",error as Any)
            }
            print("Submitted")
        }
    }
}

