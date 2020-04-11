//
//  EventData.swift
//  playdate-sandbox
//
//  Created by Jared Rankin on 2020-02-28.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import Foundation
import Firebase

typealias EventDataType = [String: Any]

// to be deprecated or reworked into new data scheme
struct EventData {
    
    var id: String
    var updated: Timestamp
    var source: String
    var sourceId: String
    
    var title: String
    var description: String
    var category: EventCategory
    var dates: EventDates
    
    var venue: EventVenue
    var buyTicketsUrl: String?
    
    init(id: String, source: String, sourceId: String) {
        self.id = id
        self.source = source
        self.sourceId = sourceId
        
        self.title = ""
        self.description = ""
        self.category = EventCategory(category: "Other", subcategory: nil)
        self.dates = EventDates()
        
        self.venue = EventVenue(
            name: "",
            address: nil,
            coordinates: GeoPoint(latitude: 0.0, longitude: 0.0),
            timeZone: "UTC",
            info: [:]
        )
        
        self.updated = Timestamp()
    }
}

struct WrappedTimestamp {
    var timestamp: Timestamp
}

struct EventDates {
    var start: WrappedTimestamp?
    var end: WrappedTimestamp?
}

struct EventCategory {
    var category: String
    var subcategory: String?
}

struct EventVenue {
    var name: String
    var address: VenueAddress?
    var coordinates: GeoPoint
    var timeZone: String
    var info: [String: Any]
}

struct VenueAddress {
    var street: [String]
    var city: String
    var state: String
    var postCode: String
}
