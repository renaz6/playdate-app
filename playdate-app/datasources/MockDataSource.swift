//
//  MockDataSource.swift
//  playdate-sandbox
//
//  Created by Jared Rankin on 2020-02-28.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import Foundation

public class MockDataSource: EventDataSource {
    
    let events = [
        ["title": "Event 1", "venue": "Venue 1", "imageId": "calendar", "startDate": Date(timeIntervalSince1970: 1591736400)],
        ["title": "Event 2", "venue": "Venue 1", "imageId": "music.mic", "startDate": Date(timeIntervalSince1970: 1591736400)],
        ["title": "Event 3", "venue": "Venue 2", "imageId": "calendar", "startDate": Date(timeIntervalSince1970: 1591736400)],
        ["title": "Event 4", "venue": "Venue 3", "imageId": "person.2.fill", "startDate": Date(timeIntervalSince1970: 1591736400)],
        ["title": "Event 5", "venue": "Venue 3", "imageId": "calendar", "startDate": Date(timeIntervalSince1970: 1591736400)]
    ]
    
    public func homePageEvents() -> [[String: Any]] {
        return events
    }
    
    public func searchEvents(_ query: String) -> [[String: Any]] {
        return events
    }
    
    public func searchEvents(_ query: String, withCategory category: String) -> [[String: Any]] {
        return events
    }
    
    public func event(withId id: String) -> [String: Any]? {
        if let index = Int(id), index < events.count {
            return events[index]
        } else {
            return nil
        }
    }
}
