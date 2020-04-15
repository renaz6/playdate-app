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

class EventDetailViewController: UIViewController {

    var event: EventDataType!
    var coordinates: GeoPoint?
    private var dataSource: EventDataSource!
    var url:String!
    let toWebsite = "toWebsiteSegue"
    var userEmail: String!
    var starred: Bool! = false

    // Outlets
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var venueLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var favBtnImage = UIImage(named: "favIcon")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
        eventLocation.text = eventData.venueName
        
        // Location/venue: icon and headings
        venueLabel.text = eventData.venueName
        addressLabel.text = eventData.venueAddressStreet[0]
        
        // Date/Time
        dateLabel.text = describeDate(eventData.datesStart?.dateValue())
        timeLabel.text = describeTime(eventData.datesStart?.dateValue())
        
        // Set location on the map using MapKit and coordinates from the event
        coordinates = eventData.venueCoordinates
        let initialLocation = CLLocation(latitude: coordinates!.latitude, longitude: coordinates!.longitude)
        mapView.centerToLocation(initialLocation)
        
        // Map annotations
        let venueBuilding = MKPointAnnotation()
        venueBuilding.title = eventData.venueName
        venueBuilding.coordinate = CLLocationCoordinate2D(latitude: coordinates!.latitude, longitude: coordinates!.longitude)
        mapView.addAnnotation(venueBuilding)
        
        // Set URL
        url = eventData.ticketsURL
        
        // Set the star button image
        // Check to see if the user has the event saved
        print(event.id)
        dataSource.isEventStarred(withId: event.id) { (result) in
            self.starred = result
        }
        
        // If the user has the event saved, show the saved icon
               
        if(starred) {
            favBtnImage = UIImage(named: "favIconSelected")
        }
        
        favButton.setImage(favBtnImage , for: .normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == toWebsite,
            let dest = segue.destination as? WebsiteViewController{

            dest.ticketsUrl = url
        }
    }

    @IBAction func favButtonClicked(_ sender: Any) {
        
        // Saving an event
        var error: Bool!
        if favBtnImage == UIImage(named: "favIcon"){
            
            if(userEmail != nil) {
                favBtnImage = UIImage(named: "favIconSelected")
                
                // Add the starred events
                dataSource.setEventStarred(withId: event.id, starred: true) { (result) in
                    error = result
                }
                
                print(error ?? "-")
            }
            else {
                let alert = UIAlertController(title: "Please Sign In.", message: "Please sign in or make an account to save this event.", preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))

                self.present(alert, animated: true)
            }
            
        }
        else { // Unsaving an event
            
            favBtnImage = UIImage(named: "favIcon")
            dataSource.setEventStarred(withId: event.id, starred: false) { (result) in
                error = result
            }
        }
      
        favButton.setImage(favBtnImage, for: .normal)
    }
    
    // Function that formats the date for the date label
    private func describeDate(_ date: Date?) -> String {
        if let date = date {
            let dateFormat = DateFormatter()
           // let timeFormat = DateFormatter()
            dateFormat.dateStyle = .medium
            dateFormat.timeZone = .autoupdatingCurrent
            //timeFormat.timeStyle = .short
            
            return dateFormat.string(from: date)
            
        } else {
            return ""
        }
    }
    
    // Function that formats the time for the time label
    private func describeTime(_ date: Date?) -> String {
        if let date = date {
            
           let timeFormat = DateFormatter()
            timeFormat.timeStyle = .short
            timeFormat.timeZone = .autoupdatingCurrent
            
            return timeFormat.string(from: date)
            
        } else {
            return ""
        }
    }
    
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
    
}

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

