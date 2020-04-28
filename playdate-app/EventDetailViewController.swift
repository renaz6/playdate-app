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
    @IBOutlet weak var descriptionLabel: UILabel!
    
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
        

        descriptionLabel.text = eventData.categorySubcategory
        

        
        // Location/venue: icon and headings
        venueLabel.text = eventData.venueName
        addressLabel.text = eventData.venueAddressStreet[0]
        
        // Date/Time
        dateLabel.text = eventData.startDateDescription
        timeLabel.text = eventData.startTimeDescription
        
        // Set location on the map using MapKit and coordinates from the event
        coordinates = eventData.venueCoordinates
        let initialLocation = CLLocation(latitude: coordinates!.latitude, longitude: coordinates!.longitude)
        mapView.centerToLocation(initialLocation)
        
        // Map annotations
        let venueBuilding = MKPointAnnotation()
        venueBuilding.title = eventData.venueName
//        venueBuilding.coordinate = CLLocationCoordinate2D(latitude: coordinates!.latitude, longitude: coordinates!.longitude)
//        mapView.addAnnotation(venueBuilding)
        
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

