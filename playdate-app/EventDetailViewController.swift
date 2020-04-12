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
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var favBtnImage = UIImage(named: "favIcon")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        dataSource = AppDelegate.instance.dataSource
        
        // Set Event Data
        let eventData = event!
        imageOutlet.image = UIImage(systemName: eventData.imageId)
        eventName.text = eventData.title
        eventLocation.text = eventData.venueName
        
        // Map, Set location
        coordinates = eventData.venueCoordinates
        let initialLocation = CLLocation(latitude: coordinates!.latitude, longitude: coordinates!.longitude)
        mapView.centerToLocation(initialLocation)
        
        // Buttons
        favButton.setImage(favBtnImage , for: .normal)
    }
    
    
    @IBAction func favButtonClicked(_ sender: Any) {
        if favBtnImage == UIImage(named: "favIcon"){
            favBtnImage = UIImage(named: "favIconSelected")
 
        }
        else{
            favBtnImage = UIImage(named: "favIcon")
        }
        favButton.setImage(favBtnImage , for: .normal)
        
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

