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
    
    var description: String {
        return self["description"] as! String
    }
    
    var cancelled: Bool {
        return self["cancelled"] as! Bool
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
    
    // Local category for app purposes
    // Theatre, Comedy, Music, Fine Art, Misc
    var localCategory: String {
        return self["localCategory"] as! String
    }
    
    
    // MARK: - Date description
    
    var startDateTimeDescription: String {
        let startDateComp = (self["dates"] as! [String: Any])["start"] as! [String: Any]
        
        let dateDesc = describeDateComponent(startDateComp)
        if let time = dateDesc.time {
            return dateDesc.date + ", " + time
        } else {
            return dateDesc.date
        }
    }
    
    var startDateDescription: String {
        let startDateComp = (self["dates"] as! [String: Any])["start"] as! [String: Any]
        return describeDateComponent(startDateComp).date
    }
    
    var startTimeDescription: String {
        let startDateComp = (self["dates"] as! [String: Any])["start"] as! [String: Any]
        return describeDateComponent(startDateComp).time ?? ""
    }
    
    var endDateTimeDescription: String {
        let endDateComp = (self["dates"] as! [String: Any])["end"] as! [String: Any]
        
        let dateDesc = describeDateComponent(endDateComp)
        if let time = dateDesc.time {
            return dateDesc.date + ", " + time
        } else {
            return dateDesc.date
        }
    }
    
    var endDateDescription: String {
        let endDateComp = (self["dates"] as! [String: Any])["end"] as! [String: Any]
        return describeDateComponent(endDateComp).date
    }
    
    var endTimeDescription: String {
        let endDateComp = (self["dates"] as! [String: Any])["end"] as! [String: Any]
        return describeDateComponent(endDateComp).time ?? ""
    }
    
    private func describeDateComponent(_ dateComponent: [String: Any]) -> (date: String, time: String?) {
        if let _ = dateComponent["localDate"] as? String,
            let timestamp = dateComponent["timestamp"] as? Timestamp {
            
            // we interpret timestamp as a UTC date
            // localDate is redundant, and only present to trigger this behaviour
            return (date: describeUTCDate(timestamp.dateValue()), time: nil)
        }
        else if let timestamp = dateComponent["timestamp"] as? Timestamp {
            return describeDateTime(timestamp.dateValue())
        } else {
            return (date: "TBD", time: nil)
        }
    }
    
    // Describe a date and time in the system's date format and time zone.
    private func describeDateTime(_ date: Date?) -> (date: String, time: String?) {
        if let date = date {
            let dateFormat = DateFormatter()
            let timeFormat = DateFormatter()
            dateFormat.dateStyle = .medium
            timeFormat.timeStyle = .short
            dateFormat.timeZone = .autoupdatingCurrent
            timeFormat.timeZone = .autoupdatingCurrent
            
            return (date: dateFormat.string(from: date), time: timeFormat.string(from: date))
        } else {
            return (date: "TBD", time: nil)
        }
    }
    
    // Describe a date (by itself) in the system locale's date format.
    private func describeUTCDate(_ date: Date?) -> String {
        if let date = date {
            let dateFormat = DateFormatter()
            dateFormat.dateStyle = .medium
            dateFormat.timeZone = TimeZone(identifier: "UTC")
            
            return dateFormat.string(from: date)
        } else {
            return "TBD"
        }
    }
    
    // MARK: - Conversion from TMEvent
    
    static func from(_ tmEvent: TMEvent) -> EventDataType {
        // TM gives us the date in RFC 3339 form - we will attempt to parse it
        // in event of failure, startDate is nil (indicated to user as TBD)
        let isoFormatter = DateFormatter()
        isoFormatter.locale = Locale(identifier: "en_US_POSIX")
        isoFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        isoFormatter.timeZone = TimeZone(identifier: "UTC")
        
        // TM can give us a few different types of dates
        //   - the standard one, where dateTime is set
        //   - "non-specific time", where dateTime is unset, localDate is set and noSpecificTime is true
        //   - TBA, where dateTBA is true
        var startDateComponent: [String: Any] = [:]
        if let startDateWrapper = tmEvent.dates.start, !startDateWrapper.dateTBA {
            if startDateWrapper.noSpecificTime {
                let localDate = startDateWrapper.localDate
                startDateComponent["localDate"] = localDate
                
                // add redundant timestamp for sorting, description
                // note that the time will be [date], 00:00:00 UTC
                // so consumers must use UTC when displaying the date if localDate is present
                let format = DateFormatter()
                format.dateFormat = "yyyy-MM-dd"
                if let date = format.date(from: localDate ?? "") {
                    startDateComponent["timestamp"] = Timestamp(date: date)
                }
            } else {
                let startDate = isoFormatter.date(from: startDateWrapper.dateTime ?? "")
                startDateComponent["timestamp"] = startDate != nil ? Timestamp(date: startDate!) : nil
            }
        }
        
        var endDateComponent: [String: Any] = [:]
        if let endDateWrapper = tmEvent.dates.end {
            if endDateWrapper.noSpecificTime {
                let localDate = endDateWrapper.localDate
                endDateComponent["localDate"] = localDate
                
                // add redundant timestamp for sorting, description
                let format = DateFormatter()
                format.dateFormat = "yyyy-MM-dd"
                if let date = format.date(from: localDate ?? "") {
                    endDateComponent["timestamp"] = Timestamp(date: date)
                }
            } else {
                let endDate = isoFormatter.date(from: endDateWrapper.dateTime ?? "")
                endDateComponent["timestamp"] = endDate != nil ? Timestamp(date: endDate!) : nil
            }
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
        
        // choose a local category and an icon
        var localCategory = "miscellaneous"
        var icon = "misc"
        
        switch category {
        case "Children's Theatre", "Miscellaneous Theatre", "Puppetry", "Variety", "Theatre":
            localCategory = "Theatre"
            icon = "theatreMasks"
        case "Classical", "Music", "Opera":
            localCategory = "Music"
            icon = "music"
        case "Comedy":
            localCategory = "Comedy"
            icon = "comedy"
        case "Dance", "Fine Art", "Multimedia", "Performance Art", "Spectacular":
            localCategory = "Fine Art"
            icon = "art"
        default:
            break
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
        
        var event: EventDataType = [
            "updated": Timestamp(),
            
            "id": "tm-\(tmEvent.id)",
            "source": "ticketmaster",
            "sourceId": tmEvent.id,
            "title": tmEvent.name,
            "description": tmEvent.info ?? "",
            "cancelled": tmEvent.dates.status.code == "cancelled",
            "buyTicketsUrl": tmEvent.url,
            "imageId": icon,
            "localCategory": localCategory,
            
            "category": [
                "category": category,
                "subcategory": subcategory
            ],
            
            "dates": [
                "start": startDateComponent,
                "end": endDateComponent
            ]
            
            // the compiler can't handle the size of this structure
            // so I've moved venue out of it
        ]
        
        event["venue"] = [
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
        
        return event
    }
}
