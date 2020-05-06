//
//  EventDetailViewController.swift
//  playdate-app
//
//  Created by Serena  Zamarripa on 4/3/20.
//  Copyright © 2020 Serena Zamarripa. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import MessageUI
import EventKit

class EventDetailViewController: UIViewController {

    var event: EventDataType!
    var coordinates: GeoPoint?
    private var dataSource: EventDataSource!
    var url:String!
    let toWebsite = "toWebsiteSegue"
    var userEmail: String!
    var starred: Bool! = false
    let eventStore = EKEventStore()

    // MARK: - Outlets
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var venueLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var favBtnImage = UIImage(named: "favIcon")
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.title = event.title
    }
    
    override func viewWillAppear(_ animated: Bool) {
        dataSource = AppDelegate.instance.dataSource
        let eventData = event!
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if(user != nil) {
                self.userEmail = user!.email!

                if(user == nil)
                {
                    self.favBtnImage = UIImage(named: "favIconSelected")
                }
            }
        }
        
        // Set Event Data
        // Text Labels and Images
        
        // Large Heading: Main icon, name, location
        imageOutlet.image = UIImage(named: eventData.imageId)
        eventName.text = eventData.title
        eventName.font = UIFont(name: "Gibson-Bold", size: 24)
        
        eventLocation.text = eventData.venueName
        eventLocation.font = UIFont(name: "Gibson-Regular", size: 20)

        descriptionLabel.text = eventData.categorySubcategory
        descriptionLabel.font = UIFont(name: "Gibson-Regular", size: 20)
                
        // Location/venue: icon and headings
        venueLabel.text = eventData.venueName
        venueLabel.font = UIFont(name: "Gibson-Regular", size: 20)
        addressLabel.text = eventData.venueAddressStreet[0]
        addressLabel.font = UIFont(name: "Gibson-Regular", size: 20)
        
        // Date/Time
        dateLabel.text = eventData.startDateDescription
        dateLabel.font = UIFont(name: "Gibson-Regular", size: 20)
        timeLabel.text = eventData.startTimeDescription
        timeLabel.font = UIFont(name: "Gibson-Regular", size: 20)
        
        // Set location on the map using MapKit and coordinates from the event
        coordinates = eventData.venueCoordinates
        let initialLocation = CLLocation(latitude: coordinates!.latitude, longitude: coordinates!.longitude)
        mapView.centerToLocation(initialLocation)
        
        // Map annotations
        let venueBuilding = MKPointAnnotation()
        venueBuilding.title = eventData.venueName
        
        let location = "\(eventData.venueAddressStreet),\(String(describing: eventData.venueAddressCity)), \(String(describing: eventData.venueAddressState)), \(String(describing: eventData.venueAddressPostCode))"
        //let location = "some address, state, and zip"
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { [weak self] placemarks, error in
            if let placemark = placemarks?.first, let location = placemark.location {
                let mark = MKPlacemark(placemark: placemark)

                if var region = self?.mapView.region {
                    region.center = location.coordinate
                    region.span.longitudeDelta /= 8.0
                    region.span.latitudeDelta /= 8.0
                    self?.mapView.setRegion(region, animated: true)
                    self?.mapView.addAnnotation(mark)
                }
            }
        }
        
        // Set URL
        url = eventData.ticketsURL
        
        // Set the star button image
        // Check to see if the user has the event saved
        // If the user has the event saved, show the saved icon
        favBtnImage = UIImage(named: "favIcon")
        favButton.setImage(favBtnImage, for: .normal)
        dataSource.isEventStarred(withId: event.id) { starred in
            self.starred = starred
            if starred {
                self.favBtnImage = UIImage(named: "favIconSelected")
                self.favButton.setImage(self.favBtnImage, for: .normal)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == toWebsite,
            let dest = segue.destination as? WebsiteViewController{

            dest.ticketsUrl = url
        }
    }
    
    // MARK: - Actions

    @IBAction func favButtonClicked(_ sender: Any) {
        
        // Saving an event
        if favBtnImage == UIImage(named: "favIcon") {
            
            if(userEmail != nil) {
                
                // Add the starred events
                dataSource.setEventStarred(withId: event.id, starred: true) { newState in
                    // if newState == true, we successfully starred the event
                    if newState {
                        self.favBtnImage = UIImage(named: "favIconSelected")
                        self.favButton.setImage(self.favBtnImage, for: .normal)
                        
                        // Alert user about saved event
                        let alert = UIAlertController(title: "Event Saved.", message: "You've saved this event to your profile.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                }
            }
            else {
                
                // Alert user to sign in
                let alert = UIAlertController(title: "Please Sign In.", message: "Please sign in or make an account to save this event.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
            
        }
        else { // Unsaving an event
            
            dataSource.setEventStarred(withId: event.id, starred: false) { newState in
                // if newState == false, we successfully unstarred the event
                if !newState {
                    self.favBtnImage = UIImage(named: "favIcon")
                    self.favButton.setImage(self.favBtnImage, for: .normal)
                }
            }
        }
    }
    
    @IBAction func shareButtonClicked(_ sender: Any) {
        print("shareButtonClicked(_:):", event.shareDescription)
        let activityController = UIActivityViewController(activityItems: [event.shareDescription], applicationActivities: nil)
        activityController.excludedActivityTypes = [.assignToContact, .openInIBooks, .saveToCameraRoll]
        if !MFMessageComposeViewController.canSendText() {
            activityController.excludedActivityTypes?.append(.message)
        }
        if !MFMailComposeViewController.canSendMail() {
            activityController.excludedActivityTypes?.append(.mail)
        }
        
        activityController.completionWithItemsHandler = { type, completed, returnedItems, error in
            if completed {
                print("shareButtonClicked(_:): user selected activity", type.debugDescription)
            } else {
                print("shareButtonClicked(_:): user did not complete activity")
            }
        }
        
        present(activityController, animated: true)
    }
    
    // MARK: - Map view delegate
    
    // Converts the map annotation into a view that can be displayed on the app
    // For drisplaying a pin at the given coordinates
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }

        return annotationView
    }
    
    
    // MARK: - Calendar Stuff
    
    @IBAction func calendarButtonClicked(_ sender: Any) {
        print("*** calendarButtonClicked(_:): on main thread:", Thread.current.isMainThread)
        
        let startDate = self.event.datesStart?.dateValue()
        let endDate = self.event.datesEnd?.dateValue()
        
        if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
            eventStore.requestAccess(to: .event, completion: {
                granted, error in
                
                guard error == nil else {
                    DispatchQueue.main.async {
                        print("[WARN] Couldn't access user's calendar: \(error!.localizedDescription)")
                        self.alertErrorMessage("We couldn't access your calendar due to an error.")
                    }
                    return
                }
                
                if granted {
                    DispatchQueue.main.async {
                        self.createEvent(
                            title: self.event.title,
                            startDate: startDate,
                            endDate: endDate)
                    }
                } else {
                    DispatchQueue.main.async {
                        print("[WARN] calendarButtonClicked(_:): User denied access to the calendar.")
                        self.alertErrorMessage("This feature requires access to your calendar. Please grant PlayDate access to Calendars in Settings.")
                    }
                }
            })
        } else {
            createEvent(title: event.title,
                        startDate: startDate,
                        endDate: endDate)
        }
    }
    
    func createEvent(title:String, startDate:Date?, endDate:Date?) {
        print("*** createEvent(title:startDate:endDate:): on main thread:", Thread.current.isMainThread)
        
        let event = EKEvent(eventStore: eventStore)
        
        // Construct the event
        event.title = title
        event.startDate = startDate
        event.endDate = endDate ?? startDate?.addingTimeInterval(60 * 60)
        event.notes = self.event.shareDescription
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            // Save the event to the calendar
            // "span" means "just this one" or "all subsequent events"
            try eventStore.save(event, span: .thisEvent)

            // Alert user about saved event
            let alert = UIAlertController(title: "Event Added.", message: "You've saved this event to your device's Calendar.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
            
            
            // save an identifier so I can refer to this event later
            //savedEventId = event.eventIdentifier
            
            //eventLabel.text = "Event added to calendar"
        } catch let error as NSError {
            print("Error: \(error).")
            let alert = UIAlertController(title: "Error", message: "We couldn't save this event.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    private func alertErrorMessage(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}

// MARK: -

private extension MKMapView {
  func centerToLocation(
    _ location: CLLocation,
    regionRadius: CLLocationDistance = 1000
  ) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}

