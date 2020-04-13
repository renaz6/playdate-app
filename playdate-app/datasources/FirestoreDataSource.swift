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
        
        downloadPageOfTMEvents(limit: 50) { events in
            events.forEach { event in
                print(event.id, ": ", event.title, "@", event.datesStart?.dateValue())
                self.firestore.collection("events").document(event.id).setData(event)
            }
        }
    }
    
    // MARK: - EventDataSource implementation
    
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
        if let user = Auth.auth().currentUser {
            
            firestore.collection("users").document(user.uid).getDocument { doc, error in
                if let savedEventIds = doc?.data()?["savedEvents"] as? [String] {
                    var savedEventsMutable = savedEventIds
                    if starred, !savedEventsMutable.contains(id) {
                        savedEventsMutable.append(id)
                    } else if !starred, let index = savedEventsMutable.firstIndex(of: id) {
                        savedEventsMutable.remove(at: index)
                    }
                    self.firestore.collection("users").document(user.uid).updateData(["savedEvents": savedEventsMutable]) { error in
                        handler(true)
                    }
                }
            }
        } else {
            handler(false)
        }
    }
    
    // MARK: - Support methods
    
    func downloadPageOfTMEvents(limit: Int, completion handler: @escaping ([EventDataType]) -> Void) {
        let eventsDownloadUrl = "https://app.ticketmaster.com/discovery/v2/events.json"
        + "?size=\(limit)&classificationId=\(tmFilterClassification)"
        + "&geoPoint=\(tmGeoPoint)&radius=\(tmMilesRadius)&unit=miles&apikey=\(tmApiKey)"
        
        AF.request(eventsDownloadUrl)
            .responseDecodable(of: TMEventCollectionEmbedder.self) { response in
                if response.error != nil {
                    print("Invalid response received from TM")
                    print(response.error!)
                    handler([])
                } else if let tmEventCollection = response.value?._embedded {
                    print(tmEventCollection)
                    handler(tmEventCollection.events.map { EventDataType.from($0) })
                }
        }
    }
    
    func downloadTMEvent(withId id: String, completion handler: @escaping (EventDataType?) -> Void) {
        AF.request("https://app.ticketmaster.com/discovery/v2/events/\(id)?locale=en-us&apikey=\(tmApiKey)")
            .responseDecodable(of: TMEvent.self) { response in
                if response.error != nil {
                    print("Invalid response received from TM, or no event found for id \(id)")
                    print(response.error!)
                    handler(nil)
                } else if let tmEvent = response.value {
                    handler(EventDataType.from(tmEvent))
                }
        }
    }
}
