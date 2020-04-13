//
//  EventDataUtil.swift
//  playdate-app
//
//  Created by Jared Rankin on 2020-04-10.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import Foundation
import Firebase

// Convenience fields for dictionary-based event data,
// so we don't have to write out all these typecasts
extension EventDataType {
    var id: String {
        return self["id"] as! String
    }
    
    var source: String {
        return self["source"] as! String
    }
    
    var sourceId: String {
        return self["sourceId"] as! String
    }
    
    var title: String {
        return self["title"] as! String
    }
    
    var imageId: String {
        return self["imageId"] as! String
    }
    
    var categoryCategory: String {
        return (self["category"] as! [String: Any])["category"] as! String
    }
    
    var categorySubcategory: String {
        return (self["category"] as! [String: Any])["subcategory"] as! String
    }
    
    var datesStart: Timestamp? {
        return ((self["dates"] as! [String: Any])["start"] as! [String: Any])["timestamp"] as? Timestamp
    }
    
    var datesEnd: Timestamp? {
        return ((self["dates"] as! [String: Any])["end"] as! [String: Any])["timestamp"] as? Timestamp
    }
    
    var venueName: String {
        return (self["venue"] as! [String: Any])["name"] as! String
    }
    
    var venueCoordinates: GeoPoint? {
        return (self["venue"] as! [String: Any])["coordinates"] as? GeoPoint
    }
    
    var venueAddressStreet: [String] {
        return ((self["venue"] as! [String: Any])["address"] as! [String: Any])["street"] as! [String]
    }
    
    var venueAddressCity: String {
        return ((self["venue"] as! [String: Any])["address"] as! [String: Any])["city"] as! String
    }
    
    var venueAddressState: String {
        return ((self["venue"] as! [String: Any])["address"] as! [String: Any])["state"] as! String
    }
    
    var venueAddressPostCode: String {
        return ((self["venue"] as! [String: Any])["address"] as! [String: Any])["postCode"] as! String
    }
    
    var ticketsURL: String {
        return self["buyTicketsURL"] as? String ?? ""
    }
}
