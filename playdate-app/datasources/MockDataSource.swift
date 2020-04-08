//
//  MockDataSource.swift
//  playdate-sandbox
//
//  Created by Jared Rankin on 2020-02-28.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import Foundation

class MockDataSource: EventDataSource {
    
    let events = [
        ["id": "tm-IW93nFI39j2oFNie", "title": "Event 1", "venue": "Venue 1", "imageId": "calendar", "startDate": Date(timeIntervalSince1970: 1591736400)],
        ["id": "tm-M939VNnkwjMWoje2", "title": "Event 2", "venue": "Venue 1", "imageId": "music.mic", "startDate": Date(timeIntervalSince1970: 1591736400)],
        ["id": "tm-mOOmiinF93n92nki", "title": "Event 3", "venue": "Venue 2", "imageId": "calendar", "startDate": Date(timeIntervalSince1970: 1591736400)],
        ["id": "tm-xMi20NVooqmbwkCo", "title": "Event 4", "venue": "Venue 3", "imageId": "person.2.fill", "startDate": Date(timeIntervalSince1970: 1591736400)],
        ["id": "utg-gMc3OmCz", "title": "Event 5", "venue": "Venue 3", "imageId": "calendar", "startDate": Date(timeIntervalSince1970: 1591736400)]
    ]
    
    let idLookupTable = [
        "tm-IW93nFI39j2oFNie": 0,
        "tm-M939VNnkwjMWoje2": 1,
        "tm-mOOmiinF93n92nki": 2,
        "tm-xMi20NVooqmbwkCo": 3,
        "utg-gMc3OmCz": 4
    ]
    
    public func homePageEvents() -> [[String: Any]] {
        return events
    }
    
    public func starredEvents() -> [[String : Any]] {
        return events
    }
    
    public func searchEvents(_ query: String) -> [[String: Any]] {
        return events
    }
    
    public func searchEvents(_ query: String, withCategory category: String) -> [[String: Any]] {
        return events
    }
    
    public func event(withId id: String) -> [String: Any]? {
        if let index = idLookupTable[id] {
            return events[index]
        } else {
            return nil
        }
    }
    
    public func setEventStarred(withId id: String, starred: Bool) -> Bool {
        return false
    }
}
