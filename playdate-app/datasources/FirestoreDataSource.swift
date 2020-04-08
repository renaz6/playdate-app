//
//  FirestoreDataSource.swift
//  playdate-app
//
//  Created by Jared Rankin on 2020-04-07.
//  Copyright © 2020 Jared Rankin. All rights reserved.
//

import Foundation
import Firebase
import Alamofire

class FirestoreDataSource: EventDataSource, EventUserInteractionManager {
    
    let tmFilterClassification = "KZFzniwnSyZfZ7v7na" // "Arts & Theatre"
    let tmGeoPoint = "9v6kpz7ds" // rough approximation of Texas Capitol Building, Austin, TX
    let tmMilesRadius = 50
    
    var tmApiKey: String!
    
    init() {
        let resPath = Bundle.main.path(forResource: "TM-API-Info", ofType: "plist")
        if let resPath = resPath, let plist = NSDictionary(contentsOfFile: resPath) {
            tmApiKey = (plist["API_KEY"] as! String)
        } else {
            print("[FATAL] TM-API-Info not found or corrupt.")
            abort()
        }
    }
    
    func homePageEvents() -> [[String : Any]] {
        // query: events happening now or in the future
        return []
    }
    
    func starredEvents() -> [[String : Any]] {
        return []
    }
    
    func searchEvents(_ query: String) -> [[String : Any]] {
        // query: events with titles or descriptions like query
        return []
    }
    
    func searchEvents(_ query: String, withCategory category: String) -> [[String : Any]] {
        // query: events with titles or descriptions like query, and categorised as category
        return []
    }
    
    func event(withId id: String) -> [String : Any]? {
        // a single event with this ID, or nil
        return nil
    }
    
    func setEventStarred(withId id: String, starred: Bool) -> Bool {
        return false
    }
}
