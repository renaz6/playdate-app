//
//  EventDataUtil.swift
//  playdate-app
//
//  Created by Jared Rankin on 2020-04-10.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import Foundation
import Firebase

extension EventDataType {
    // MARK: - Convenience fields

    // Convenience fields for dictionary-based event data,
    // so we don't have to write out all these typecasts
    
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
    
    var venueAddressCity: String? {
        return ((self["venue"] as! [String: Any])["address"] as! [String: Any])["city"] as? String
    }
    
    var venueAddressState: String? {
        return ((self["venue"] as! [String: Any])["address"] as! [String: Any])["state"] as? String
    }
    
    var venueAddressPostCode: String? {
        return ((self["venue"] as! [String: Any])["address"] as! [String: Any])["postCode"] as? String
    }
    
    var ticketsURL: String {
        return self["buyTicketsUrl"] as? String ?? ""
    }
    
    // MARK: - Conversion from TMEvent
    
    static func from(_ tmEvent: TMEvent) -> EventDataType {
        // TM gives us the date in RFC 3339 form - we will attempt to parse it
        // in event of failure, startDate is nil (indicated to user as TBD)
        let isoFormatter = DateFormatter()
        isoFormatter.locale = Locale(identifier: "en_US_POSIX")
        isoFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        isoFormatter.timeZone = TimeZone(identifier: "UTC")
        
        var startDate: Date?
        if !tmEvent.dates.start.dateTBA {
            startDate = isoFormatter.date(from: tmEvent.dates.start.dateTime ?? "")
        }
        
        // see if TM gave us at least one category to go off of
        var category: String?
        var subcategory: String?
        if tmEvent.classifications.isEmpty {
            category = "Other"
            subcategory = "Other"
        } else {
            // I've now seen TM give me events without even a 'genre'
            // so that requirement is no longer enforced
            category = tmEvent.classifications[0].genre?.name ?? "Other"
            subcategory = tmEvent.classifications[0].subGenre?.name ?? "Other"
        }
        
        // make sure we have at least one venue
        var venue: TMVenue?
        if tmEvent._embedded.venues.isEmpty {
            print("no venue found")
        } else {
            venue = tmEvent._embedded.venues[0]
        }
        // resolve street address
        var streets: [String] = []
        if let street1 = venue?.address?.line1 {
            streets.append(street1)
        }
        if let street2 = venue?.address?.line2 {
            streets.append(street2)
        }
        
        let event: EventDataType = [
            "updated": Timestamp(),
            
            "id": "tm-\(tmEvent.id)",
            "source": "ticketmaster",
            "sourceId": tmEvent.id,
            "title": tmEvent.name,
            "buyTicketsUrl": tmEvent.url,
            "imageId": "theatreMasks",
            
            "category": [
                "category": category,
                "subcategory": subcategory
            ],
            
            "dates": [
                "start": [
                    "timestamp": startDate != nil ? Timestamp(date: startDate!) : nil
                ]
            ],
            
            "venue": [
                "name": venue?.name ?? "Unknown",
                "timeZone": venue?.timezone ?? "UTC",
                "address": [
                    "street": streets,
                    "city": (venue?.city?.name) ?? "",
                    "state": (venue?.state?.stateCode) ?? "",
                    "postCode": (venue?.postalCode) ?? ""
                ],
                "coordinates": GeoPoint(
                    latitude: Double(venue?.location?.latitude ?? "") ?? 0.0,
                    longitude: Double(venue?.location?.longitude ?? "") ?? 0.0
                )
            ]
        ]
        
        return event
    }
}
