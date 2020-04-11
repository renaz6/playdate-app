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

class FirestoreDataSource: EventDataSource {
    
    let homePageEventsCap = 20
    let tmFilterClassification = "KZFzniwnSyZfZ7v7na" // "Arts & Theatre"
    let tmGeoPoint = "9v6kpz7ds" // rough approximation of Texas Capitol Building, Austin, TX
    let tmMilesRadius = 50
    
    var firestore: Firestore
    var tmApiKey: String
    
    init() {
        firestore = Firestore.firestore()
        
        let resPath = Bundle.main.path(forResource: "TM-API-Info", ofType: "plist")
        if let resPath = resPath, let plist = NSDictionary(contentsOfFile: resPath) {
            tmApiKey = (plist["API_KEY"] as! String)
        } else {
            print("[FATAL] TM-API-Info not found or corrupt.")
            abort()
        }
    }
    
    func homePageEvents(completion handler: @escaping ([EventDataType]) -> Void) {
        // query: at most N events happening now or in the future
        firestore.collection("events")
            .whereField(FieldPath(["dates", "start", "timestamp"]), isGreaterThanOrEqualTo: Timestamp())
            .limit(to: homePageEventsCap)
            .getDocuments(completion: { result, error in
                if error == nil, let docs = result?.documents {
                    handler(docs.map { $0.data() })
                }
            })
    }
    
    func starredEvents(completion handler: @escaping ([EventDataType]) -> Void) {
        if let user = Auth.auth().currentUser {
            
            firestore.collection("users").document(user.uid).getDocument { doc, error in
                
                if let savedEventIds = doc?.data()?["savedEvents"] as? [String] {
                    self.firestore.collection("events")
                        .whereField("id", in: savedEventIds)
                        .getDocuments { result, error in
                            
                            if error == nil, let docs = result?.documents {
                                handler(docs.map { $0.data() })
                            }
                    }
                }
            }
        } else {
            handler([])
        }
    }
    
    func searchEvents(_ query: String, completion handler: @escaping ([EventDataType]) -> Void) {
        // query: events with titles or descriptions like query
        handler([])
    }
    
    func searchEvents(_ query: String, withCategory category: String, completion handler: @escaping ([EventDataType]) -> Void) {
        // query: events with titles or descriptions like query, and categorised as category
        handler([])
    }
    
    func event(withId id: String, completion handler: @escaping (EventDataType?) -> Void) {
        // a single event with this ID, or nil
        let docRef = firestore.collection("events").document(id)
        
        docRef.getDocument { doc, error in
            if let error = error {
                print("Could not fetch event", id, error)
            } else {
                handler(doc?.data())
            }
        }
    }
    
    func setEventStarred(withId id: String, starred: Bool, completion handler: @escaping (Bool) -> Void) {
        handler(false)
    }
}
