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
    
    let homePageEventsCap = 40
    let tmFilterClassification = "KZFzniwnSyZfZ7v7na" // "Arts & Theatre"
    let tmGeoPoint = "9v6kpz7ds" // rough approximation of Texas Capitol Building, Austin, TX
    let tmMilesRadius = 50
    let tmSort = "date,name,asc"
    
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
        
        // 200 is TM-imposed cap per page
        downloadPageOfTMEvents(limit: 200) { events in
            events.forEach { event in
                if event.cancelled {
                    self.firestore.collection("events").document(event.id).delete()
                } else {
                    self.firestore.collection("events").document(event.id).setData(event)
                }
            }
        }
    }
    
    // MARK: - EventDataSource implementation
    
    func allEvents(completion handler: @escaping ([EventDataType]) -> Void) {
        firestore.collection("events")
            .whereField(FieldPath(["dates", "start", "timestamp"]), isGreaterThanOrEqualTo: Timestamp())
            .getDocuments(completion: { result, error in
                if error == nil, let docs = result?.documents {
                    handler(docs.map { $0.data() })
                }
            })
    }
    
    func eventsOnDate(year: Int, month: Int, day: Int, completion handler: @escaping ([EventDataType]) -> Void) {
        // query: all events happening on (within 24 hours of) year-month-day in the user's time zone
        if let beginningOfDay = DateComponents(year: year, month: month, day: day).date,
            let nextDay = DateComponents(year: year, month: month, day: day).date?.addingTimeInterval(60*60*24) {
            
            firestore.collection("events")
            .whereField(FieldPath(["dates", "start", "timestamp"]),
                        isGreaterThanOrEqualTo: Timestamp(date: beginningOfDay))
            .whereField(FieldPath(["dates", "start", "timestamp"]),
                        isLessThan: Timestamp(date: nextDay))
            .getDocuments(completion: { result, error in
                if error == nil, let docs = result?.documents {
                    handler(docs.map { $0.data() })
                }
            })
        }
    }
    
    func eventsWithCategory(_ category: String, completion handler: @escaping ([EventDataType]) -> Void) {
        // query: events where localCategory == category
        firestore.collection("events")
            .whereField("localCategory", isEqualTo: category)
            .whereField(FieldPath(["dates", "start", "timestamp"]), isGreaterThanOrEqualTo: Timestamp()) 
            .getDocuments(completion: { result, error in
                if error == nil, let docs = result?.documents {
                    handler(docs.map { $0.data() })
                }
            })
    }
    
    func homePageEvents(completion handler: @escaping ([EventDataType]) -> Void) {
        // query: at most N events happening now or in the future
        firestore.collection("events")
            .whereField(FieldPath(["dates", "start", "timestamp"]), isGreaterThanOrEqualTo: Timestamp())
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
                    if savedEventIds.isEmpty {
                        handler([])
                    } else {
                        self.firestore.collection("events")
                            .whereField("id", in: savedEventIds)
                            .whereField(FieldPath(["dates", "start", "timestamp"]), isGreaterThanOrEqualTo: Timestamp())
                            .getDocuments { result, error in
                                
                                if error == nil, let docs = result?.documents {
                                    handler(docs.map { $0.data() })
                                }
                        }
                    }
                }
            }
        } else {
            handler([])
        }
    }
    
    func searchEvents(_ query: String, completion handler: @escaping ([EventDataType]) -> Void) {
        // not used
        handler([])
    }
    
    func searchEvents(_ query: String, withCategory category: String, completion handler: @escaping ([EventDataType]) -> Void) {
        // not used
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
    
    func isEventStarred(withId id: String, completion handler: @escaping (Bool) -> Void) {
        if let user = Auth.auth().currentUser {
            
            firestore.collection("users").document(user.uid).getDocument { doc, error in
                if let savedEventIds = doc?.data()?["savedEvents"] as? [String] {
                    handler(savedEventIds.contains(id))
                }
            }
        } else {
            handler(false)
        }
    }
    
    func setEventStarred(withId id: String, starred: Bool, completion handler: @escaping (Bool) -> Void) {
        if let user = Auth.auth().currentUser {
            
            firestore.collection("users").document(user.uid).getDocument { doc, error in
                if let savedEventIds = doc?.data()?["savedEvents"] as? [String] {
                    var savedEventsMutable = savedEventIds
                    let starredNow = savedEventsMutable.contains(id)
                    
                    if starred, !starredNow {
                        savedEventsMutable.append(id)
                    } else if !starred, let index = savedEventsMutable.firstIndex(of: id) {
                        savedEventsMutable.remove(at: index)
                    }
                    self.firestore.collection("users").document(user.uid).updateData(["savedEvents": savedEventsMutable]) { error in
                        if error == nil {
                            handler(starred)
                        } else {
                            handler(starredNow)
                        }
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
        + "&geoPoint=\(tmGeoPoint)&radius=\(tmMilesRadius)&sort=\(tmSort)&unit=miles&apikey=\(tmApiKey)"
        
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

extension DateComponents {
    init(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0, second: Int = 0, nanosecond: Int = 0) {
        self.init(
            calendar: .autoupdatingCurrent,
            timeZone: .autoupdatingCurrent,
            year: year, month: month, day: day,
            hour: hour, minute: minute, second: second, nanosecond: nanosecond
        )
    }
}
